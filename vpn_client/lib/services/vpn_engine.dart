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

  String get singBoxPath {
    // В режиме разработки ищем в папке проекта
    if (Platform.isWindows) {
      final devPath = p.join(Directory.current.path, 'sing-box', 'sing-box.exe');
      if (File(devPath).existsSync()) return devPath;
    }
    // В продакшене ищем рядом с exe
    return p.join(exeDir, 'sing-box.exe');
  }

  String get configPath => p.join(exeDir, 'config.json');

  String get wintunPath {
    // В режиме разработки ищем в папке проекта
    if (Platform.isWindows) {
      final devPath = p.join(Directory.current.path, 'sing-box', 'wintun.dll');
      if (File(devPath).existsSync()) return devPath;
    }
    // В продакшене ищем рядом с exe
    return p.join(exeDir, 'wintun.dll');
  }

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
    // Проверяем версию sing-box как простейший способ убедиться, что файл работает
    return await Process.run(singBoxPath, ['version']);
  }

  Future<Process> startSingBox() async {
    _process = await Process.start(singBoxPath, ['-c', configPath]);
    // даём процессу момент, чтобы завершиться при ошибке
    await Future.delayed(Duration(milliseconds: 100));
    return _process!;
  }

  /// Generate sing-box configuration from template and save to [configPath].
  Future<void> generateConfig(Server server,
      {AssetBundle? bundle}) async {
    final assetBundle = bundle ?? rootBundle;
    final template = await assetBundle.loadString('sing-box/config_template.json');
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
  Future<void> writeConfig(Server server, {AssetBundle? bundle}) async {
    await generateConfig(server, bundle: bundle ?? rootBundle);
  }

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

  /// Комплексная проверка готовности системы к работе VPN
  Future<Map<String, dynamic>> diagnoseSystem() async {
    final result = <String, dynamic>{
      'ready': false,
      'errors': <String>[],
      'warnings': <String>[],
      'checks': <String, bool>{}
    };

    // 1. Проверка исполняемого файла sing-box
    final singBoxFile = File(singBoxPath);
    final singBoxExists = await singBoxFile.exists();
    result['checks']['sing-box.exe'] = singBoxExists;
    if (!singBoxExists) {
      result['errors'].add('Не найден файл sing-box.exe по пути: $singBoxPath');
      result['errors'].add('');
      result['errors'].add('ИНСТРУКЦИЯ ПО УСТАНОВКЕ:');
      result['errors'].add('1. Перейдите на https://github.com/SagerNet/sing-box/releases');
      result['errors'].add('2. Скачайте файл sing-box-{version}-windows-amd64.exe');
      result['errors'].add('3. Переименуйте его в sing-box.exe');
      result['errors'].add('4. Поместите в папку build/windows/runner/Release/ рядом с vpn_client.exe');
    }

    // 2. Проверка Wintun DLL (только для Windows)
    if (Platform.isWindows) {
      final wintunFile = File(wintunPath);
      final wintunExists = await wintunFile.exists();
      result['checks']['wintun.dll'] = wintunExists;
      if (!wintunExists) {
        result['errors'].add('Не найден файл wintun.dll по пути: $wintunPath');
        result['errors'].add('');
        result['errors'].add('ИНСТРУКЦИЯ ПО УСТАНОВКЕ WINTUN:');
        result['errors'].add('1. Перейдите на https://www.wintun.net/');
        result['errors'].add('2. Скачайте "Wintun Library"');
        result['errors'].add('3. Извлеките файл bin/amd64/wintun.dll из архива');
        result['errors'].add('4. Поместите wintun.dll рядом с vpn_client.exe');
      }
    } else {
      result['checks']['wintun.dll'] = true; // На Linux не нужен
    }

    // 3. Проверка прав администратора (косвенно через создание TUN-адаптера)
    if (Platform.isWindows && result['checks']['wintun.dll'] == true) {
      try {
        final tunReady = await ensureTunAdapter();
        result['checks']['tun_adapter'] = tunReady;
        if (!tunReady) {
          result['errors'].add('Не удается создать TUN-адаптер. Требуются права администратора.');
        }
      } catch (e) {
        result['checks']['tun_adapter'] = false;
        result['errors'].add('Ошибка при создании TUN-адаптера: $e');
      }
    } else {
      result['checks']['tun_adapter'] = !Platform.isWindows; // На Linux проще с TUN
    }

    // 4. Проверка конфигурационного шаблона
    try {
      final template = await rootBundle.loadString('sing-box/config_template.json');
      result['checks']['config_template'] = template.isNotEmpty;
      if (template.isEmpty) {
        result['errors'].add('Пустой конфигурационный шаблон');
      }
    } catch (e) {
      result['checks']['config_template'] = false;
      result['errors'].add('Не удается загрузить конфигурационный шаблон: $e');
    }

    // 5. Тест запуска sing-box (если файл существует)
    if (singBoxExists) {
      try {
        final testResult = await testSingBox();
        result['checks']['sing_box_test'] = testResult.exitCode == 0;
        if (testResult.exitCode != 0) {
          final error = testResult.stderr.toString();
          result['warnings'].add('sing-box test завершился с ошибкой: $error');
        }
      } catch (e) {
        result['checks']['sing_box_test'] = false;
        result['errors'].add('Не удается запустить sing-box test: $e');
      }
    } else {
      result['checks']['sing_box_test'] = false;
    }

    // Общая готовность
    result['ready'] = result['checks'].values.every((check) => check == true);

    return result;
  }

  /// Более детальная проверка TUN-адаптера с диагностикой
  Future<Map<String, dynamic>> checkTunAdapter() async {
    final result = <String, dynamic>{
      'available': false,
      'error': '',
      'details': <String>[]
    };

    if (!Platform.isWindows) {
      result['available'] = true;
      result['details'].add('Linux: TUN поддерживается системой');
      return result;
    }

    final dllFile = File(wintunPath);
    if (!await dllFile.exists()) {
      result['error'] = 'Файл wintun.dll не найден';
      result['details'].add('Путь: $wintunPath');
      result['details'].add('Решение: Скачайте wintun.dll из официального сайта Wintun');
      return result;
    }

    try {
      final lib = DynamicLibrary.open(wintunPath);
      
      // Проверяем доступность функций
      try {
        lib.lookupFunction<
            Pointer<Void> Function(Pointer<Utf16>),
            Pointer<Void> Function(Pointer<Utf16>)>('WintunOpenAdapter');
        result['details'].add('✓ Функция WintunOpenAdapter найдена');
      } catch (e) {
        result['error'] = 'Неверная версия wintun.dll';
        result['details'].add('✗ Функция WintunOpenAdapter недоступна');
        return result;
      }

      try {
        lib.lookupFunction<
            Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>),
            Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>)>('WintunCreateAdapter');
        result['details'].add('✓ Функция WintunCreateAdapter найдена');
      } catch (e) {
        result['error'] = 'Неверная версия wintun.dll';
        result['details'].add('✗ Функция WintunCreateAdapter недоступна');
        return result;
      }

      // Пытаемся создать адаптер
      final success = await ensureTunAdapter();
      if (success) {
        result['available'] = true;
        result['details'].add('✓ TUN-адаптер XVPN создан успешно');
      } else {
        result['error'] = 'Не удалось создать TUN-адаптер';
        result['details'].add('✗ Возможные причины:');
        result['details'].add('  - Нет прав администратора');
        result['details'].add('  - Драйвер Wintun не установлен');
        result['details'].add('  - Другой VPN уже использует адаптер');
      }

    } catch (e) {
      result['error'] = 'Ошибка при загрузке wintun.dll: $e';
      result['details'].add('Возможно поврежден файл wintun.dll');
    }

    return result;
  }
}
