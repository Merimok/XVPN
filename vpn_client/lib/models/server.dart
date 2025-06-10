import 'dart:convert';

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
    this.pbk = '',
    this.sni = '',
    this.sid = '',
    this.fp = 'chrome',
  });

  factory Server.fromJson(Map<String, dynamic> json) => Server(
        name: json['name'] ?? json['address'],
        address: json['address'],
        port: json['port'],
        id: json['id'],
        pbk: json['pbk'] ?? '',
        sni: json['sni'] ?? '',
        sid: json['sid'] ?? '',
        fp: json['fp'] ?? 'chrome',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'port': port,
        'id': id,
        'pbk': pbk,
        'sni': sni,
        'sid': sid,
        'fp': fp,
      };
}

Server? parseVless(String url) {
  try {
    final uri = Uri.parse(url.trim());
    if (uri.scheme != 'vless') return null;
    final id = uri.userInfo;
    if (id.isEmpty) return null;
    final address = uri.host;
    if (address.isEmpty) return null;
    final port = uri.port == 0 ? 443 : uri.port;
    final name = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : address;
    final query = uri.queryParameters;
    return Server(
      name: name,
      address: address,
      port: port,
      id: id,
      pbk: query['pbk'] ?? '',
      sni: query['sni'] ?? '',
      sid: query['sid'] ?? '',
      fp: query['fp'] ?? 'chrome',
    );
  } catch (_) {
    return null;
  }
}
