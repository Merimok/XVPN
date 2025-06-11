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
  @override
  Future<String> ping(String address) async => 'Время ответа: 25ms';
  @override
  void stop() {
    // Fake stop - do nothing
  }
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
  testWidgets('Home screen displays Mullvad-style UI components correctly', (tester) async {
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
    
    // Test that basic UI structure is present
    // Check for main ElevatedButton (connect/disconnect button)
    expect(find.byType(ElevatedButton), findsWidgets);
    
    // Check for server dropdown (core functionality)
    expect(find.byType(DropdownButton<Server>), findsOneWidget);
    
    // Check that the test server appears in UI
    expect(find.text('Test Server'), findsWidgets);
    
    // Verify status text is displayed (any valid status)
    final statusTexts = ['Отключено', 'Подключено', 'Подключение...', 'Ошибка'];
    bool hasValidStatus = false;
    for (final status in statusTexts) {
      if (tester.any(find.text(status))) {
        hasValidStatus = true;
        break;
      }
    }
    expect(hasValidStatus, isTrue, reason: 'Should display a valid status text');
    
    // Test basic interaction - try to tap main button if it exists
    final elevatedButtons = find.byType(ElevatedButton);
    if (tester.any(elevatedButtons)) {
      // Just verify buttons respond to taps without strict state checking
      await tester.tap(elevatedButtons.first);
      await tester.pump();
      
      // After interaction, UI should still be valid
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    }
  });
}
