import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/server.dart';
import '../services/server_repository.dart';
import '../services/vpn_engine.dart';

class VpnProvider extends ChangeNotifier {
  final ServerRepository repository;
  final VpnEngine engine;

  List<Server> servers = [];
  Server? selected;
  String ping = '';
  String status = 'Отключено';
  String logOutput = '';
  bool filesReady = false;

  VpnProvider({required this.repository, required this.engine});

  Future<void> init() async {
    try {
      servers = await repository.loadServers();
      if (servers.isNotEmpty) selected = servers.first;
    } catch (e) {
      logOutput = 'Не удалось загрузить список серверов\n$e';
    }
    
    // Проверяем наличие необходимых файлов
    filesReady = await engine.checkFiles();
    if (!filesReady) {
      logOutput += '\nНе найдены необходимые файлы (sing-box.exe)';
    }
    
    notifyListeners();
  }

  /// Полная диагностика готовности системы
  Future<void> runDiagnostics() async {
    logOutput = 'Запуск диагностики...\n';
    notifyListeners();

    try {
      final diagnosis = await engine.diagnoseSystem();
      
      logOutput += '=== ДИАГНОСТИКА СИСТЕМЫ ===\n';
      
      // Показать результаты проверок
      final checks = diagnosis['checks'] as Map<String, bool>;
      checks.forEach((check, result) {
        final status = result ? '✓' : '✗';
        logOutput += '$status $check: ${result ? 'OK' : 'FAILED'}\n';
      });
      
      // Показать ошибки
      final errors = diagnosis['errors'] as List<String>;
      if (errors.isNotEmpty) {
        logOutput += '\n=== ОШИБКИ ===\n';
        for (final error in errors) {
          logOutput += '• $error\n';
        }
      }
      
      // Показать предупреждения
      final warnings = diagnosis['warnings'] as List<String>;
      if (warnings.isNotEmpty) {
        logOutput += '\n=== ПРЕДУПРЕЖДЕНИЯ ===\n';
        for (final warning in warnings) {
          logOutput += '• $warning\n';
        }
      }
      
      // Общий статус
      final ready = diagnosis['ready'] as bool;
      logOutput += '\n=== РЕЗУЛЬТАТ ===\n';
      logOutput += ready 
          ? '✓ Система готова к работе VPN' 
          : '✗ Система НЕ готова к работе VPN';
      
      filesReady = ready;
      
    } catch (e) {
      logOutput += 'Ошибка диагностики: $e\n';
      filesReady = false;
    }
    
    notifyListeners();
  }

  Future<void> addServer(Server server) async {
    // Проверяем базовые параметры (UUID может быть любым непустым строковым идентификатором)
    if (server.id.isEmpty ||
        server.address.isEmpty ||
        server.port <= 0) {
      logOutput += 'Неверные параметры сервера\n';
      notifyListeners();
      return;
    }
    if (servers.any((s) => s.id == server.id)) {
      logOutput += 'Сервер с таким ID уже существует\n';
      notifyListeners();
      return;
    }
    servers.add(server);
    selected = server;
    try {
      await repository.saveServers(servers);
    } catch (e) {
      logOutput += 'Ошибка сохранения сервера\n$e\n';
    }
    notifyListeners();
  }

  Future<void> removeServer(Server server) async {
    if (server.isBuiltIn) {
      logOutput += 'Нельзя удалить встроенный сервер\n';
      notifyListeners();
      return;
    }
    servers.remove(server);
    if (selected == server) {
      selected = servers.isNotEmpty ? servers.first : null;
    }
    try {
      await repository.saveServers(servers);
    } catch (e) {
      logOutput += 'Ошибка сохранения списка серверов\n$e\n';
    }
    notifyListeners();
  }

  void selectServer(Server? s) {
    selected = s;
    notifyListeners();
  }

  Future<void> connect() async {
    if (selected == null) return;

    status = 'Подключение...';
    logOutput = '';
    notifyListeners();

    if (!await engine.ensureTunAdapter()) {
      status = 'Ошибка';
      logOutput =
          'Не удалось зарегистрировать TUN-адаптер. Убедитесь, что Wintun установлен и вы запустили приложение с правами администратора.';
      notifyListeners();
      return;
    }

    if (!await engine.checkFiles()) {
      status = 'Ошибка';
      logOutput = 'Не найдены исполняемые файлы sing-box';
      notifyListeners();
      return;
    }

    try {
      await engine.generateConfig(selected!, bundle: rootBundle);
    } catch (e) {
      status = 'Ошибка';
      logOutput = 'Ошибка генерации конфигурации\n$e';
      notifyListeners();
      return;
    }

    // Проверяем сгенерированную конфигурацию
    try {
      final checkResult = await Process.run(engine.singBoxPath, ['check', '-c', engine.configPath]);
      if (checkResult.exitCode != 0) {
        status = 'Ошибка';
        final checkErr = (checkResult.stderr is List<int>) ? utf8.decode(checkResult.stderr) : checkResult.stderr.toString();
        logOutput = 'Ошибка в конфигурации: ${checkErr.isNotEmpty ? checkErr : 'Неизвестная ошибка'}';
        notifyListeners();
        return;
      }
    } catch (e) {
      status = 'Ошибка';
      logOutput = 'Не удалось проверить конфигурацию\n$e';
      notifyListeners();
      return;
    }

    final test = await engine.testSingBox();
    final err = (test.stderr is List<int>) ? utf8.decode(test.stderr) : test.stderr.toString();
    if (test.exitCode != 0) {
      status = 'Ошибка';
      logOutput = err.isNotEmpty ? err : 'Не удалось запустить sing-box';
      notifyListeners();
      return;
    }

    try {
      final proc = await engine.startSingBox();
      
      // Слушаем stdout и stderr
      proc.stdout.transform(utf8.decoder).listen((e) {
        logOutput += e;
        notifyListeners();
      });
      proc.stderr.transform(utf8.decoder).listen((e) {
        logOutput += e;
        notifyListeners();
      });
      
      // Проверяем что процесс не завершился сразу (даем время на инициализацию)
      await Future.delayed(Duration(milliseconds: 500));
      
      // Проверяем статус процесса без блокировки
      bool processRunning = true;
      try {
        // Проверяем завершился ли процесс без ожидания
        final exitCode = proc.exitCode;
        // Если exitCode доступен немедленно, процесс уже завершился
        if (exitCode.isCompleted) {
          final code = await exitCode;
          status = 'Ошибка';
          logOutput += '\nsing-box завершился сразу с кодом: $code\n';
          processRunning = false;
        } else {
          // Процесс еще работает
          status = 'Подключено';
          logOutput += '\nПроцесс sing-box запущен успешно (PID: ${proc.pid})\n';
          
          // Асинхронно следим за завершением процесса
          exitCode.then((code) {
            if (status == 'Подключено') {
              status = 'Ошибка';
              logOutput += '\nsing-box завершился с кодом: $code\n';
              notifyListeners();
            }
          });
        }
      } catch (e) {
        // Если произошла ошибка при проверке процесса
        status = 'Ошибка';
        logOutput += '\nОшибка проверки процесса: $e\n';
        processRunning = false;
      }
      
      notifyListeners();
    } catch (e) {
      status = 'Ошибка';
      logOutput = 'Не удалось подключиться\n$e';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      engine.stop();
    } finally {
      status = 'Отключено';
      logOutput += '\nПроцесс остановлен';
      notifyListeners();
    }
  }

  Future<void> measurePing() async {
    if (selected == null) return;
    try {
      ping = await engine.ping(selected!.address);
    } catch (e) {
      ping = 'Ошибка ping: $e';
    }
    notifyListeners();
  }
}
