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
