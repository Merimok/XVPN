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
