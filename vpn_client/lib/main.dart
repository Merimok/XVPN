import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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
    final template = await File('sing-box/config_template.json').readAsString();
    final config = template
        .replaceAll('{{address}}', selected!.address)
        .replaceAll('{{port}}', selected!.port.toString())
        .replaceAll('{{id}}', selected!.id)
        .replaceAll('{{pbk}}', selected!.pbk)
        .replaceAll('{{sni}}', selected!.sni)
        .replaceAll('{{sid}}', selected!.sid)
        .replaceAll('{{fp}}', selected!.fp);
    final configPath = 'sing-box/config.json';
    await File(configPath).writeAsString(config);
    _process = await Process.start('sing-box/sing-box.exe', ['run', '-c', configPath]);
    setState(() {});
  }

  Future<void> _disconnect() async {
    _process?.kill();
    _process = null;
    setState(() {});
  }

  Future<void> _measurePing() async {
    if (selected == null) return;
    final result = await Process.run('ping', ['-n', '1', selected!.address]);
    setState(() {
      ping = result.stdout.toString();
    });
  }

  Future<void> _addServer() async {
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
              title: const Text('Add Server'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                  TextField(controller: portController, decoration: const InputDecoration(labelText: 'Port')),
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
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final s = Server(
                        name: nameController.text,
                        address: addressController.text,
                        port: int.tryParse(portController.text) ?? 0,
                        id: idController.text,
                        pbk: pbkController.text,
                        sni: sniController.text,
                        sid: sidController.text,
                        fp: fpController.text,
                      );
                      setState(() {
                        servers.add(s);
                        selected = s;
                      });
                      _saveServers();
                      Navigator.pop(context);
                    },
                    child: const Text('Add')),
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
        appBar: AppBar(title: const Text('VLESS VPN Client')),
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
                  ElevatedButton(onPressed: _process == null ? _connect : null, child: const Text('Connect')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _process != null ? _disconnect : null, child: const Text('Disconnect')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addServer, child: const Text('Add')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _removeServer, child: const Text('Remove')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _measurePing, child: const Text('Ping')),
                ],
              ),
              const SizedBox(height: 16),
              Text('Status: ${_process == null ? 'Disconnected' : 'Connected'}'),
              const SizedBox(height: 8),
              Text('Ping result:\n$ping'),
            ],
          ),
        ),
      ),
    );
  }
}
