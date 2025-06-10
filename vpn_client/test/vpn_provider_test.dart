import 'package:flutter_test/flutter_test.dart';
import 'package:vpn_client/models/server.dart';
import 'package:vpn_client/state/vpn_provider.dart';
import 'package:vpn_client/services/server_repository.dart';
import 'package:vpn_client/services/vpn_engine.dart';

class MemoryServerRepository extends ServerRepository {
  List<Server> data = [];
  MemoryServerRepository() : super();
  @override
  Future<List<Server>> loadServers() async => data;
  @override
  Future<void> saveServers(List<Server> servers) async {
    data = List.from(servers);
  }
}

class DummyEngine extends VpnEngine {}

void main() {
  test('addServer validation', () async {
    final repo = MemoryServerRepository();
    final provider = VpnProvider(repository: repo, engine: DummyEngine());
    await provider.init();

    // invalid server
    await provider.addServer(Server(name: 'n', address: '', port: 0, id: '123'));
    expect(provider.servers, isEmpty);
    expect(provider.lastOperationResult, startsWith('error:'));
    expect(provider.logOutput, contains('Неверные параметры сервера'));

    // valid server
    provider.logOutput = '';
    provider.clearLastOperationResult();
    final valid = Server(
        name: 'ok',
        address: 'host',
        port: 1,
        id: '11111111-1111-1111-1111-111111111111');
    await provider.addServer(valid);
    expect(provider.servers.length, 1);
    expect(provider.lastOperationResult, 'success');
    expect(provider.logOutput, contains('успешно добавлен'));
  });
}
