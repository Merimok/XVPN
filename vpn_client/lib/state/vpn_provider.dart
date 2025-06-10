import 'dart:io';
import 'dart:convert';
import 'dart:async';

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
  String? _lastOperationResult; // Для отслеживания результата последней операции

  VpnProvider({required this.repository, required this.engine});

  /// Возвращает результат последней операции (null, 'success', 'error:<message>')
  String? get lastOperationResult => _lastOperationResult;
  
  /// Очищает результат последней операции
  void clearLastOperationResult() {
    _lastOperationResult = null;
  }

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
    _lastOperationResult = null;
    
    // Проверяем базовые параметры
    if (server.id.isEmpty ||
        server.address.isEmpty ||
        server.port <= 0) {
      _lastOperationResult = 'error:Неверные параметры сервера';
      logOutput += 'Неверные параметры сервера\n';
      notifyListeners();
      return;
    }
    
    // Проверяем дублирование по комбинации адрес:порт (более практично)
    if (servers.any((s) => s.address == server.address && s.port == server.port)) {
      _lastOperationResult = 'error:Сервер ${server.address}:${server.port} уже существует';
      logOutput += 'Сервер ${server.address}:${server.port} уже существует\n';
      notifyListeners();
      return;
    }
    
    logOutput += 'Добавляем сервер: ${server.name} (${server.address}:${server.port})\n';
    
    try {
      servers.add(server);
      selected = server;
      await repository.saveServers(servers);
      _lastOperationResult = 'success';
      logOutput += 'Сервер успешно добавлен! Всего серверов: ${servers.length}\n';
    } catch (e) {
      // Если произошла ошибка, удаляем сервер из списка
      servers.remove(server);
      if (selected == server) {
        selected = servers.isNotEmpty ? servers.first : null;
      }
      _lastOperationResult = 'error:Ошибка сохранения сервера: $e';
      logOutput += 'Ошибка сохранения сервера: $e\n';
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
      try {
        // Проверяем завершился ли процесс с помощью timeout
        final exitCodeFuture = proc.exitCode;
        bool processFinished = false;
        int? exitCode;
        
        // Пытаемся получить код завершения с коротким timeout
        try {
          exitCode = await exitCodeFuture.timeout(Duration(milliseconds: 50));
          processFinished = true;
        } on TimeoutException {
          // Процесс еще работает - это нормально
          processFinished = false;
        }
        
        if (processFinished) {
          status = 'Ошибка';
          logOutput += '\nsing-box завершился сразу с кодом: $exitCode\n';
          processRunning = false;
        } else {
          // Процесс еще работает
          status = 'Подключено';
          logOutput += '\nПроцесс sing-box запущен успешно (PID: ${proc.pid})\n';
          
          // Асинхронно следим за завершением процесса
          exitCodeFuture.then((code) {
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
    
    ping = 'Измерение...';
    notifyListeners();
    
    try {
      final result = await engine.ping(selected!.address);
      // Парсим время из разных форматов пинга
      final timeRegexRu = RegExp(r'время[<>=]\s*(\d+)\s*мс');
      final timeRegexEn = RegExp(r'time[<>=]\s*(\d+(?:\.\d+)?)\s*ms');
      final timeRegexMs = RegExp(r'(\d+(?:\.\d+)?)\s*ms');
      
      final matchRu = timeRegexRu.firstMatch(result);
      final matchEn = timeRegexEn.firstMatch(result);
      final matchMs = timeRegexMs.firstMatch(result);
      
      if (matchRu != null) {
        ping = '${matchRu.group(1)}ms';
      } else if (matchEn != null) {
        ping = '${matchEn.group(1)}ms';
      } else if (matchMs != null) {
        ping = '${matchMs.group(1)}ms';
      } else {
        ping = 'N/A';
      }
    } catch (e) {
      ping = 'Ошибка';
    }
    notifyListeners();
  }
}
