import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/server_repository.dart';
import 'services/vpn_engine.dart';
import 'state/vpn_provider.dart';
import 'screens/home_screen.dart';

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
      child: const MaterialApp(
        title: 'VLESS VPN',
        home: HomeScreen(),
      ),
    );
  }
}
