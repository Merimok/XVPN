import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class Server {
  String name;
  String address;
  int port;
  String id;
  String pbk;
  String sni;
  String sid;
  String fp;
  Server({
    required this.name,
    required this.address,
    required this.port,
    required this.id,
    required this.pbk,
    required this.sni,
    required this.sid,
    required this.fp,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      name: json['name'],
      address: json['address'],
      port: json['port'],
      id: json['id'],
      pbk: json['pbk'] ?? '',
      sni: json['sni'] ?? '',
      sid: json['sid'] ?? '',
      fp: json['fp'] ?? 'chrome',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'addre

