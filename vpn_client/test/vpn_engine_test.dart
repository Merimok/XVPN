import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vpn_client/services/vpn_engine.dart';

class FakeProcess extends Process {
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
}

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

void main() {
  test('vpn engine start/stop', () async {
    final engine = FakeVpnEngine();
    final proc = await engine.startSingBox();
    expect(proc.pid, 1);
    engine.stop();
  });
}
