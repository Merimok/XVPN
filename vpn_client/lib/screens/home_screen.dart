import 'package:flutter/material.dart';
import 'server_screen.dart';
import 'settings_screen.dart';
import 'log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  String currentServer = "Auto";
  String latency = "-- ms";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XVPN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.shield : Icons.shield_outlined,
              size: 100,
              color: isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isConnected ? "Подключено" : "Не подключено",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text("Сервер: $currentServer | Пинг: $latency"),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  isConnected = !isConnected;
                });
              },
              child: Text(isConnected ? "Отключиться" : "Подключиться"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerScreen(),
                  ),
                );
                if (result is String) {
                  setState(() {
                    currentServer = result;
                  });
                }
              },
              child: const Text("Выбрать сервер"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: const Text("Настройки"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogScreen(),
                  ),
                );
              },
              child: const Text("Лог"),
            ),
          ],
        ),
      ),
    );
  }
}
