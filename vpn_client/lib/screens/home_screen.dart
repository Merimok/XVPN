import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/server.dart';
import '../state/vpn_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              onChanged: (s) => vpn.selectServer(s),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: vpn.filesReady && 
                              vpn.status != 'Подключено' && 
                              vpn.selected != null ? vpn.connect : null,
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
                          if (!vpn.logOutput.contains('Неверные параметры')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Сервер успешно добавлен!')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка: ${vpn.logOutput.split('\n').last}')));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный VLESS URL')));
                        }
                      }
                    },
                    child: const Text('Добавить')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: vpn.selected != null && !vpn.selected!.isBuiltIn 
                        ? () => vpn.removeServer(vpn.selected!) 
                        : null,
                    child: const Text('Удалить')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: vpn.selected != null ? vpn.measurePing : null, 
                              child: const Text('Пинг')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () => vpn.runDiagnostics(),
                    child: const Text('Диагностика')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: vpn.logOutput.isNotEmpty 
                        ? () async {
                            await Clipboard.setData(ClipboardData(text: vpn.logOutput));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Лог скопирован в буфер обмена')));
                          }
                        : null,
                    child: const Text('Копировать лог')),
              ],
            ),
            const SizedBox(height: 16),
            if (!vpn.filesReady)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '⚠️ Не найден файл sing-box.exe. Подключение невозможно.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Text('Статус: ${vpn.status}'),
            const SizedBox(height: 8),
            Text('Результат ping:\n${vpn.ping}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Лог output:'),
                if (vpn.logOutput.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: vpn.logOutput));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Лог скопирован в буфер обмена')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Копировать'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: SelectableText(vpn.logOutput), // Сделаем текст выделяемым
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
