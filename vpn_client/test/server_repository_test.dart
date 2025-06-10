import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vpn_client/services/server_repository.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  Directory dir;
  FakePathProviderPlatform(this.dir);
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return dir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load and save servers', () async {
    final tempDir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
    final repo = ServerRepository(getDirectory: () async => tempDir, bundle: rootBundle);
    // First load should copy from assets
    final servers = await repo.loadServers();
    expect(servers, isNotEmpty);
    // Save
    await repo.saveServers(servers);
    final file = File('${tempDir.path}/servers.json');
    expect(await file.exists(), isTrue);
    final list = jsonDecode(await file.readAsString()) as List;
    expect(list.length, servers.length);
  });
}
