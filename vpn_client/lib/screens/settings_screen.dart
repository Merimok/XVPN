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
