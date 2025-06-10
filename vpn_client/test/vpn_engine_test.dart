import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vpn_client/models/server.dart';
import 'package:vpn_client/services/vpn_engine.dart';

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

class FakeVpnEngine extends VpnEngine {
  FakeVpnEngine([this._configPath = 'config.json']);
  final String _configPath;

  @override
  Future<bool> ensureTunAdapter() async => true;
  @override
  Future<ProcessResult> testSingBox() async => ProcessResult(0, 0, '', '');
  @override
  Future<Process> startSingBox() async => FakeProcess();
  @override
  String get singBoxPath => 'sb.exe';
  @override
  String get configPath => _configPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('vpn engine start/stop', () async {
    final engine = FakeVpnEngine();
    final proc = await engine.startSingBox();
    expect(proc.pid, 1);
    engine.stop();
  });

  test('generateConfig generates config file', () async {
    final dir = await Directory.systemTemp.createTemp();
    final path = p.join(dir.path, 'config.json');
    final engine = FakeVpnEngine(path);
    final server = Server(
      name: 'Test',
      address: '1.1.1.1',
      port: 443,
      id: 'uuid',
      pbk: 'key',
      sni: 'sni',
      sid: 'sid',
      fp: 'fp',
    );
    await engine.generateConfig(server, bundle: rootBundle);
    final file = File(path);
    expect(await file.exists(), isTrue);
    final contents = await file.readAsString();
    expect(contents.contains(server.address), isTrue);
    expect(contents.contains(server.id), isTrue);
    await dir.delete(recursive: true);
  });
}
