import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/models/server.dart';
import 'package:vpn_client/screens/home_screen.dart';
import 'package:vpn_client/state/vpn_provider.dart';
import 'package:vpn_client/services/server_repository.dart';
import 'package:vpn_client/services/vpn_engine.dart';

class FakeVpnEngine extends VpnEngine {
  @override
  Future<bool> ensureTunAdapter() async => true;
  @override
  Future<ProcessResult> testSingBox() async => ProcessResult(0, 0, '', '');
  @override
  Future<Process> startSingBox() async => FakeProcess();
  @override
  String get singBoxPath => 'sb.exe';
  @override
  String get configPath => 'config.json';
  @override
  Future<bool> checkFiles() async => true;
  @override
  Future<Map<String, dynamic>> diagnoseSystem() async => {
    'ready': true,
    'errors': <String>[],
    'warnings': <String>[],
    'checks': <String, bool>{'sing-box.exe': true, 'wintun.dll': true, 'tun_adapter': true, 'config_template': true, 'sing_box_test': true}
  };
}

class FakeProcess implements Process {
  final StreamController<List<int>> _stderrController = StreamController<List<int>>();
  final StreamController<List<int>> _stdoutController = StreamController<List<int>>();
  final StreamController<List<int>> _stdinController = StreamController<List<int>>();
  
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
  
  @override
  int get pid => 1;
  
  @override
  Stream<List<int>> get stderr => _stderrController.stream;
  
  @override
  Stream<List<int>> get stdout => _stdoutController.stream;
  
  @override
  Future<int> get exitCode async => 0;
  
  @override
  IOSink get stdin => IOSink(_stdinController.sink);
}

void main() {
  testWidgets('Connect button changes status', (tester) async {
    // Create a provider with a sample server
    final provider = VpnProvider(
      repository: ServerRepository(), 
      engine: FakeVpnEngine()
    );
    
    // Add a sample server for testing
    await provider.init();
    if (provider.servers.isEmpty) {
      await provider.addServer(Server(
        name: 'Test Server',
        address: 'test.example.com', 
        port: 443,
        id: '11111111-1111-1111-1111-111111111111',
      ));
    }
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Должна быть кнопка "Подключиться"
    expect(find.text('Подключиться'), findsOneWidget);
    
    // Нажимаем кнопку подключения
    await tester.tap(find.text('Подключиться'));
    await tester.pump();
    
    // После нажатия статус должен измениться
    // Может быть "Подключение..." или "Подключено"
    expect(find.text('Подключиться'), findsNothing);
    
    // Ждём завершения анимации
    await tester.pumpAndSettle();
  });
}
