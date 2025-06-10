import 'dart:io';

import 'package:flutter/material.dart';

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
    servers = await repository.loadServers();
    if (servers.isNotEmpty) selected = servers.first;
    notifyListeners();
  }

  Future<void> addServer(Server server) async {
    if (servers.any((s) => s.id == server.id)) return;
    servers.add(server);
    selected = server;
    await repository.saveServers(servers);
    notifyListeners();
  }

  Future<void> removeServer(Server server) async {
    servers.remove(server);
    if (selected == server) {
      selected = servers.isNotEmpty ? servers.first : null;
    }
    await repository.saveServers(servers);
    notifyListeners();
  }

  Future<void> connect() async {
    if (selected == null) return;

    status = 'Подключение...';
    logOutput = '';
    notifyListeners();

    if (!await engine.ensureTunAdapter()) {
      status = 'Ошибка';
      logOutput = 'Не удалось зарегистрировать TUN-адаптер. Убедитесь, что Wintun установлен и вы запустили приложение с правами администратора.';
      notifyListeners();
      return;
    }

    if (!await File(engine.singBoxPath).exists() || !await File(engine.configPath).exists()) {
      status = 'Ошибка';
      logOutput = 'sing-box.exe или config.json не найдены';
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
      status = 'Подключено';
      notifyListeners();
    } catch (e) {
      status = 'Ошибка';
      logOutput = 'Не удалось подключиться\n$e';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    engine.stop();
    status = 'Отключено';
    logOutput += '\nПроцесс остановлен';
    notifyListeners();
  }

  Future<void> measurePing() async {
    if (selected == null) return;
    ping = await engine.ping(selected!.address);
    notifyListeners();
  }
}
