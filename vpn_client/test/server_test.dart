import 'package:flutter_test/flutter_test.dart';
import 'package:vpn_client/models/server.dart';

void main() {
  test('Server toJson/fromJson', () {
    final s = Server(
      name: 'Test',
      address: '1.1.1.1',
      port: 443,
      id: 'uuid',
      pbk: 'key',
      sni: 'sni',
      sid: 'sid',
      fp: 'fp',
    );
    final map = s.toJson();
    final s2 = Server.fromJson(map);
    expect(s2.name, s.name);
    expect(s2.address, s.address);
    expect(s2.port, s.port);
    expect(s2.id, s.id);
    expect(s2.pbk, s.pbk);
    expect(s2.sni, s.sni);
    expect(s2.sid, s.sid);
    expect(s2.fp, s.fp);
  });

  group('parseVless', () {
    test('full url', () {
      final url = 'vless://123@host:443?pbk=key&sni=test#Name';
      final s = parseVless(url)!;
      expect(s.name, 'Name');
      expect(s.address, 'host');
      expect(s.port, 443);
      expect(s.id, '123');
      expect(s.pbk, 'key');
      expect(s.sni, 'test');
    });

    test('no fragment', () {
      final url = 'vless://id@host:80?fp=chrome';
      final s = parseVless(url)!;
      expect(s.name, 'host');
      expect(s.port, 80);
    });

    test('invalid scheme', () {
      expect(parseVless('http://example.com'), isNull);
    });
  });
}
