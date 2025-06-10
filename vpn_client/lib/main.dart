// xvpn/lib/main.dart
// ⓘ Примечание: исполняемый файл sing-box.exe должен находиться в директории ../sing-box относительно корня проекта.
import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/server_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/log_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final exeFile = File("../sing-box/sing-box.exe");
  final exists = await exeFile.exists();

  if (!exists) {
    runApp(const MissingExeApp());
  } else {
    runApp(const XVPNApp());
  }
}
}

class MissingExeApp extends StatelessWidget {
  const MissingExeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XVPN - Ошибка',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Файл sing-box.exe не найден в папке /sing-box.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Пожалуйста, убедитесь, что он находится в нужном месте.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class XVPNApp extends StatelessWidget {
  const XVPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XVPN',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// xvpn/lib/screens/home_screen.dart
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

// xvpn/lib/screens/server_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  List<dynamic> servers = [];

  @override
  void initState() {
    super.initState();
    loadServers();
  }

  Future<void> loadServers() async {
    final jsonStr = await rootBundle.loadString('assets/servers.json');
    setState(() {
      servers = json.decode(jsonStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Выбор сервера")),
      body: servers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: servers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final server = servers[index];
                return ListTile(
                  title: Text(server['name'] ?? 'Unknown'),
                  subtitle: Text(server['address'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context, server['name']);
                  },
                );
              },
            ),
    );
  }
}

// xvpn/lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoConnect = false;
  bool killSwitch = false;
  String mode = 'Global';
  String dns = '1.1.1.1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Настройки")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Авто-подключение"),
            value: autoConnect,
            onChanged: (val) => setState(() => autoConnect = val),
          ),
          SwitchListTile(
            title: const Text("Kill Switch"),
            value: killSwitch,
            onChanged: (val) => setState(() => killSwitch = val),
          ),
          const SizedBox(height: 16),
          const Text("Режим обхода"),
          DropdownButton<String>(
            value: mode,
            isExpanded: true,
            items: ["Global", "Split Tunneling"].map((m) => DropdownMenuItem(
              value: m,
              child: Text(m),
            )).toList(),
            onChanged: (val) => setState(() => mode = val!),
          ),
          const SizedBox(height: 16),
          const Text("DNS"),
          TextField(
            controller: TextEditingController(text: dns),
            decoration: const InputDecoration(hintText: "Введите DNS"),
            onChanged: (val) => dns = val,
          )
        ],
      ),
    );
  }
}

// xvpn/lib/screens/log_screen.dart
import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      "[INFO] Приложение запущено",
      "[INFO] Попытка подключения...",
      "[ERROR] Сервер недоступен",
      "[INFO] Переключение на резервный сервер"
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Журнал логов")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) => Text(logs[index]),
      ),
    );
  }
}
