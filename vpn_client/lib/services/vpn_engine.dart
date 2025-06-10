import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:path/path.dart' as p;

import '../models/server.dart';

class VpnEngine {
  Process? _process;

  String get exeDir => p.dirname(Platform.resolvedExecutable);

  String get singBoxPath => p.join(exeDir, 'sing-box.exe');

  String get configPath => p.join(exeDir, 'config.json');

  String get wintunPath => p.join(exeDir, 'wintun.dll');

  Future<bool> ensureTunAdapter() async {
    if (!Platform.isWindows) return true;
    final dllFile = File(wintunPath);
    if (!await dllFile.exists()) return false;
    try {
      final lib = DynamicLibrary.open(wintunPath);
      final open = lib.lookupFunction<Pointer<Void> Function(Pointer<Utf16>), Pointer<Void> Function(Pointer<Utf16>)>('WintunOpenAdapter');
      final create = lib.lookupFunction<Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>), Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>)>('WintunCreateAdapter');
      final name = 'XVPN'.toNativeUtf16();
      var handle = open(name);
      if (handle == nullptr) {
        handle = create(name, 'Wintun'.toNativeUtf16(), nullptr);
        if (handle == nullptr) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ProcessResult> testSingBox() async {
    return await Process.run(singBoxPath, ['--test']);
  }

  Future<Process> startSingBox() async {
    _process = await Process.start(singBoxPath, ['-c', configPath]);
    return _process!;
  }

  Future<void> writeConfig(Server server, {AssetBundle bundle = rootBundle}) async {
    final template = await bundle.loadString('sing-box/config_template.json');
    final config = template
        .replaceAll('{{address}}', server.address)
        .replaceAll('{{port}}', server.port.toString())
        .replaceAll('{{id}}', server.id)
        .replaceAll('{{pbk}}', server.pbk)
        .replaceAll('{{sni}}', server.sni)
        .replaceAll('{{sid}}', server.sid)
        .replaceAll('{{fp}}', server.fp);
    await File(configPath).writeAsString(config);
  }

  void stop() {
    _process?.kill();
    _process = null;
  }

  Future<String> ping(String address) async {
    final res = await Process.run('ping', ['-n', '1', address]);
    if (res.stdout is List<int>) {
      return utf8.decode(res.stdout);
    }
    return res.stdout.toString();
  }
}
