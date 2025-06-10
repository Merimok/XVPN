import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class Server {
  String name;
  String address;
  int port;
  String id;
  String pbk;
  String sni;
  String sid;
  String fp;
  Server({
    required this.name,
    required this.address,
    required this.port,
    required this.id,
    required this.pbk,
    required this.sni,
    required this.sid,
    required this.fp,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      name: json['name'],
      address: json['address'],
      port: json['port'],
      id: json['id'],
      pbk: json['pbk'] ?? '',
      sni: json['sni'] ?? '',
      sid: json['sid'] ?? '',
      fp: json['fp'] ?? 'chrome',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'port': port,
        'id': id,
        'pbk': pbk,
        'sni': sni,
        'sid': sid,
        'fp': fp,
      };
}

Server? parseVless(String url) {
  try {
    final uri = Uri.parse(url.trim());
    if (uri.scheme != 'vless') return null;
    final id = uri.userInfo;
    final address = uri.host;
    final port = uri.port;
    final query = uri.queryParameters;
    return Server(
      name: uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : address,
      address: address,
      port: port,
      id: id,
      pbk: query['pbk'] ?? '',
      sni: query['sni'] ?? '',
      sid: query['sid'] ?? '',
      fp: query['fp'] ?? 'chrome',
    );
  } catch (_) {
    return null;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Server> servers = [];
  Server? selected;
  Process? _process;
  String ping = '';
  String status = 'Отключено';
  String logOutput = '';

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    final file = File('assets/servers.json');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      setState(() {
        servers = data.map((e) => Server.fromJson(e)).toList();
        if (servers.isNotEmpty) selected = servers.first;
      });
    }
  }

  Future<void> _saveServers() async {
    final file = File('assets/servers.json');
    await file.writeAsString(jsonEncode(servers.map((e) => e.toJson()).toList()));
  }

  Future<void> _connect() async {
    if (selected == null) return;
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final exePath = p.join(exeDir, 'sing-box.exe');
    final configPath = p.join(exeDir, 'config.json');
    final wintunPath = p.join(exeDir, 'wintun.dll');

    setState(() {
      status = 'Подключение...';
      logOutput = '';
    });

    if (!await File(exePath).exists()) {
      setState(() {
        status = 'Ошибка';
        logOutput = 'sing-box.exe не найден';
      });
      return;
    }
    if (!await File(configPath).exists()) {
      setState(() {
        status = 'Ошибка';
        logOutput = 'config.json не найден';
      });
      return;
    }

    if (!await File(wintunPath).exists()) {
      setState(() {
        status = 'Ошибка';
        logOutput = 'wintun.dll не найден';
      });
      return;
    }

    // try a dry-run to detect missing permissions or TUN support
    try {
      final test = await Process.run(exePath, ['--test']);
      final err = (test.stderr is List<int>)
          ? utf8.decode(test.stderr)
          : test.stderr.toString();
      if (test.exitCode != 0) {
        setState(() {
          status = 'Ошибка';
          logOutput = err.isNotEmpty ? err : 'Не удалось запустить sing-box';
        });
        if (err.toLowerCase().contains('access')) {
          setState(() {
            logOutput +=
                '\nПожалуйста, запустите от имени администратора';
          });
        } else if (err.toLowerCase().contains('tun')) {
          setState(() {
            logOutput +=
                '\nTUN-интерфейс не поддерживается. Возможно, не хватает прав администратора или не установлен Wintun.';
          });
        }
        return;
      }
    } catch (e) {
      setState(() {
        status = 'Ошибка';
        logOutput = 'Не удалось проверить sing-box\n$e';
      });
      return;
    }

    try {
      _process = await Process.start(exePath, ['-c', configPath]);
      _process!.stdout.transform(utf8.decoder).listen((data) {
        setState(() {
          logOutput += data;
        });
      });
      _process!.stderr.transform(utf8.decoder).listen((data) {
        setState(() {
          logOutput += data;
          if (data.toLowerCase().contains('tun')) {
            logOutput +=
                '\nВозможно, требуется запустить приложение от имени администратора.';
          }
        });
      });

      setState(() {
        status = 'Подключено';
      });
    } catch (e) {
      setState(() {
        status = 'Ошибка';
        logOutput += 'Не удалось подключиться\n$e';
      });
    }
  }

  Future<void> _disconnect() async {
    _process?.kill();
    _process = null;
    setState(() {
      status = 'Отключено';
      logOutput += '\nПроцесс остановлен';
    });
  }

  Future<void> _measurePing() async {
    if (selected == null) return;
    final result = await Process.run('ping', ['-n', '1', selected!.address]);
    String out;
    if (result.stdout is List<int>) {
      out = utf8.decode(result.stdout);
    } else {
      out = result.stdout.toString();
    }
    setState(() {
      ping = out;
    });
  }

  Future<void> _addServer() async {
    final vlessController = TextEditingController();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final portController = TextEditingController();
    final idController = TextEditingController();
    final pbkController = TextEditingController();
    final sniController = TextEditingController();
    final sidController = TextEditingController();
    final fpController = TextEditingController(text: 'chrome');
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Добавить сервер'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: vlessController, decoration: const InputDecoration(labelText: 'VLESS URL')),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Адрес')),
                  TextField(controller: portController, decoration: const InputDecoration(labelText: 'Порт')),
                  TextField(controller: idController, decoration: const InputDecoration(labelText: 'UUID')),
                  TextField(controller: pbkController, decoration: const InputDecoration(labelText: 'Public Key')),
                  TextField(controller: sniController, decoration: const InputDecoration(labelText: 'SNI')),
                  TextField(controller: sidController, decoration: const InputDecoration(labelText: 'Short ID')),
                  TextField(controller: fpController, decoration: const InputDecoration(labelText: 'Fingerprint')),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Отмена')),
                TextButton(
                    onPressed: () {
                      Server? s;
                      if (vlessController.text.trim().isNotEmpty) {
                        s = parseVless(vlessController.text.trim());
                        if (s == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный VLESS URL')));
                          return;
                        }
                      } else {
                        s = Server(
                          name: nameController.text,
                          address: addressController.text,
                          port: int.tryParse(portController.text) ?? 0,
                          id: idController.text,
                          pbk: pbkController.text,
                          sni: sniController.text,
                          sid: sidController.text,
                          fp: fpController.text,
                        );
                      }
                      setState(() {
                        servers.add(s!);
                        selected = s;
                      });
                      _saveServers();
                      Navigator.pop(context);
                    },
                    child: const Text('Добавить')),
              ],
            ));
  }

  Future<void> _removeServer() async {
    if (selected == null) return;
    setState(() {
      servers.remove(selected);
      selected = servers.isNotEmpty ? servers.first : null;
    });
    await _saveServers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('VLESS VPN Клиент')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<Server>(
                isExpanded: true,
                value: selected,
                items: servers
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (s) {
                  setState(() {
                    selected = s;
                  });
                },
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: _process == null ? _connect : null, child: const Text('Подключиться')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _process != null ? _disconnect : null, child: const Text('Отключиться')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addServer, child: const Text('Добавить')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _removeServer, child: const Text('Удалить')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _measurePing, child: const Text('Пинг')),
                ],
              ),
              const SizedBox(height: 16),
              Text('Статус: $status'),
              const SizedBox(height: 8),
              Text('Результат ping:\n$ping'),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Лог output:'),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Text(logOutput),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
