import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/server.dart';

class ServerRepository {
  final Future<Directory> Function() _getDir;
  final AssetBundle _bundle;

  ServerRepository({Future<Directory> Function()? getDirectory, AssetBundle? bundle})
      : _getDir = getDirectory ?? getApplicationDocumentsDirectory,
        _bundle = bundle ?? rootBundle;

  Future<String> _filePath() async {
    final dir = await _getDir();
    return p.join(dir.path, 'servers.json');
  }

  Future<List<Server>> loadServers() async {
    final path = await _filePath();
    final file = File(path);
    String jsonStr;
    if (await file.exists()) {
      jsonStr = await file.readAsString();
    } else {
      jsonStr = await _bundle.loadString('assets/servers.json');
      await file.writeAsString(jsonStr);
    }
    final list = (jsonDecode(jsonStr) as List<dynamic>);
    return list.map((e) => Server.fromJson(e)).toList();
  }

  Future<void> saveServers(List<Server> servers) async {
    final path = await _filePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(servers.map((e) => e.toJson()).toList()));
  }
}
