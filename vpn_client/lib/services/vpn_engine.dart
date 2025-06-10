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

  /// Ensure that required binaries are available.
  Future<bool> checkFiles() async {
    final exe = File(singBoxPath);
    if (!await exe.exists()) return false;
    if (Platform.isWindows) {
      final dll = File(wintunPath);
      if (!await dll.exists()) return false;
    }
    return true;
  }

  Future<bool> ensureTunAdapter() async {
    if (!Platform.isWindows) return true;
    final dllFile = File(wintunPath);
    if (!await dllFile.exists()) return false;
    try {
      final lib = DynamicLibrary.open(wintunPath);
      final open = lib.lookupFunction<
          Pointer<Void> Function(Pointer<Utf16>),
          Pointer<Void> Function(Pointer<Utf16>)>('WintunOpenAdapter');
      final create = lib.lookupFunction<
          Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>),
          Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>)>('WintunCreateAdapter');

      // Используем промежуточные переменные для конвертации строк
      final String adapterName = "XVPN";
      final Pointer<Utf16> namePtr = adapterName.toNativeUtf16();

      Pointer<Utf16>? descPtr;
      Pointer<Void> handle = open(namePtr);

      if (handle == nullptr) {
        final String adapterDesc = "Wintun";
        descPtr = adapterDesc.toNativeUtf16();
        handle = create(namePtr, descPtr, nullptr);
        if (handle == nullptr) {
          malloc.free(namePtr);
          malloc.free(descPtr);
          return false;
        }
      }

      malloc.free(namePtr);
      if (descPtr != null) {
        malloc.free(descPtr);
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
    // даём процессу момент, чтобы завершиться при ошибке
    await Future.delayed(Duration(milliseconds: 100));
    return _process!;
  }

  /// Generate sing-box configuration from template and save to [configPath].
  Future<void> generateConfig(Server server,
      {AssetBundle bundle = rootBundle}) async {
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

  // Deprecated: keep for backward compatibility with older tests.
  Future<void> writeConfig(Server server, {AssetBundle bundle = rootBundle}) =>
      generateConfig(server, bundle: bundle);

  void stop() {
    _process?.kill();
    _process = null;
  }

  Future<String> ping(String address) async {
    final args =
        Platform.isWindows ? ['-n', '1', address] : ['-c', '1', address];
    final res = await Process.run('ping', args);
    if (res.stdout is List<int>) {
      return utf8.decode(res.stdout);
    }
    return res.stdout.toString();
  }
}
