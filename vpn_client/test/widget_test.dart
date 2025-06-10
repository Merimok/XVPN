import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/main.dart';
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
}

class FakeProcess implements Process {
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
  @override
  int get pid => 1;
  @override
  Stream<List<int>> get stderr => const Stream.empty();
  @override
  Stream<List<int>> get stdout => const Stream.empty();
  @override
  Future<int> get exitCode async => 0;
  @override
  IOSink get stdin => IOSink(StreamController<List<int>>().sink);
}

void main() {
  testWidgets('Connect button changes status', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => VpnProvider(
            repository: ServerRepository(), engine: FakeVpnEngine())..init(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Подключиться'), findsOneWidget);
    await tester.tap(find.text('Подключиться'));
    await tester.pump();
    expect(find.text('Подключено'), findsOneWidget);
  });
}
