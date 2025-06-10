import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/server.dart';
import 'services/server_repository.dart';
import 'services/vpn_engine.dart';
import 'state/vpn_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VpnProvider(
            repository: ServerRepository(),
            engine: VpnEngine(),
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'VLESS VPN',
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vpn = Provider.of<VpnProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('VLESS VPN Клиент')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Server>(
              isExpanded: true,
              value: vpn.selected,
              items: vpn.servers
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (s) => vpn.selected = s,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: vpn.status == 'Отключено' ? vpn.connect : null,
                    child: const Text('Подключиться')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: vpn.status == 'Подключено' ? vpn.disconnect : null,
                    child: const Text('Отключиться')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () async {
                      final controller = TextEditingController();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Добавить сервер'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(labelText: 'VLESS URL'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Добавить')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        final srv = parseVless(controller.text.trim());
                        if (srv != null) {
                          await vpn.addServer(srv);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный VLESS URL')));
                        }
                      }
                    },
                    child: const Text('Добавить')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed:
                        vpn.selected != null ? () => vpn.removeServer(vpn.selected!) : null,
                    child: const Text('Удалить')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: vpn.measurePing, child: const Text('Пинг')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Статус: ${vpn.status}'),
            const SizedBox(height: 8),
            Text('Результат ping:\n${vpn.ping}'),
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
                  child: Text(vpn.logOutput),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
