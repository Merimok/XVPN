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

  VpnProvider({required this.repository, required this.engine});

  Future<void> init() async {
    try {
      servers = await repository.loadServers();
      if (servers.isNotEmpty) selected = servers.first;
    } catch (e) {
      logOutput = 'Не удалось загрузить список серверов\n$e';
    }
    notifyListeners();
  }

  Future<void> addServer(Server server) async {
    final uuidReg = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\$');
    if (!uuidReg.hasMatch(server.id) ||
        server.address.isEmpty ||
        server.port <= 0) {
      logOutput += 'Неверные параметры сервера\n';
      notifyListeners();
      return;
    }
    if (servers.any((s) => s.id == server.id)) return;
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
      proc.stdout.transform(utf8.decoder).listen((e) {
        logOutput += e;
        notifyListeners();
      });
      proc.stderr.transform(utf8.decoder).listen((e) {
        logOutput += e;
        notifyListeners();
      });
      // verify process started
      if (await proc.exitCode != 0) {
        status = 'Ошибка';
        logOutput += '\nsing-box завершился преждевременно';
      } else {
        status = 'Подключено';
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
