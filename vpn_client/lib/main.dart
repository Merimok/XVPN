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
