# API Reference

This document provides detailed API reference for XVPN's internal components.

## Core APIs

### VpnProvider API

The main state management class for the application.

#### Constructor
```dart
VpnProvider({
  required ServerRepository repository,
  required VpnEngine engine
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `servers` | `List<Server>` | List of available servers |
| `selected` | `Server?` | Currently selected server |
| `ping` | `String` | Last ping result |
| `status` | `String` | Connection status |
| `logOutput` | `String` | Application logs |
| `filesReady` | `bool` | System readiness status |

#### Methods

##### `Future<void> init()`
Initialize the provider and load server configurations.

**Throws**: 
- `Exception` if server loading fails

**Example**:
```dart
final provider = VpnProvider(repository: repo, engine: engine);
await provider.init();
```

##### `Future<void> connect()`
Establish VPN connection with the selected server.

**Preconditions**: 
- `selected` server must not be null
- System files must be ready
- TUN adapter must be available

**Side Effects**:
- Updates `status` property
- Generates logs in `logOutput`
- Starts sing-box process

**Example**:
```dart
provider.selectServer(myServer);
await provider.connect();
```

##### `Future<void> disconnect()`
Terminate the current VPN connection.

**Side Effects**:
- Stops sing-box process
- Updates status to "Отключено"
- Appends disconnection log

##### `Future<void> addServer(Server server)`
Add a new server to the configuration.

**Parameters**:
- `server`: Server configuration to add

**Validation**:
- Server ID must be unique
- Required fields must be non-empty
- Port must be valid (1-65535)

**Throws**:
- `ArgumentException` for invalid server data

##### `Future<void> removeServer(Server server)`
Remove a server from the configuration.

**Parameters**:
- `server`: Server to remove

**Restrictions**:
- Built-in servers cannot be removed
- Currently connected server cannot be removed

##### `void selectServer(Server? server)`
Select a server for connection.

**Parameters**:
- `server`: Server to select, or null to deselect

##### `Future<void> runDiagnostics()`
Run comprehensive system diagnostics.

**Side Effects**:
- Updates `logOutput` with diagnostic results
- Updates `filesReady` status
- Notifies listeners

##### `Future<void> measurePing()`
Measure ping to the selected server.

**Preconditions**:
- `selected` server must not be null

**Side Effects**:
- Updates `ping` property with result

---

### VpnEngine API

Core VPN functionality and system integration.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `singBoxPath` | `String` | Path to sing-box executable |
| `configPath` | `String` | Path to generated configuration |
| `wintunPath` | `String` | Path to Wintun DLL |

#### Methods

##### `Future<bool> checkFiles()`
Verify that required binary files exist.

**Returns**: `true` if all files are present

**Example**:
```dart
final ready = await engine.checkFiles();
if (!ready) {
  print('Missing required files');
}
```

##### `Future<bool> ensureTunAdapter()`
Create or verify TUN adapter availability.

**Returns**: `true` if adapter is ready

**Platform**: Windows only (returns `true` on other platforms)

**Requires**: Administrator privileges

##### `Future<ProcessResult> testSingBox()`
Test sing-box executable functionality.

**Returns**: Process result with exit code and output

**Command**: `sing-box version`

##### `Future<Process> startSingBox()`
Start the sing-box VPN process.

**Returns**: Running process instance

**Command**: `sing-box run -c <configPath>`

**Throws**:
- `ProcessException` if process fails to start

##### `Future<void> generateConfig(Server server, {AssetBundle? bundle})`
Generate sing-box configuration from template.

**Parameters**:
- `server`: Server configuration
- `bundle`: Asset bundle for template loading (optional)

**Side Effects**:
- Creates configuration file at `configPath`

**Template Variables**:
- `{{address}}` → server.address
- `{{port}}` → server.port
- `{{id}}` → server.id
- `{{pbk}}` → server.pbk
- `{{sni}}` → server.sni
- `{{sid}}` → server.sid
- `{{fp}}` → server.fp

##### `void stop()`
Stop the running sing-box process.

**Side Effects**:
- Kills process if running
- Clears process reference

##### `Future<String> ping(String address)`
Ping a network address.

**Parameters**:
- `address`: Hostname or IP address to ping

**Returns**: Ping command output

**Command**: 
- Windows: `ping -n 1 <address>`
- Unix: `ping -c 1 <address>`

##### `Future<Map<String, dynamic>> diagnoseSystem()`
Comprehensive system readiness check.

**Returns**: Diagnostic results map with structure:
```dart
{
  'ready': bool,           // Overall readiness
  'errors': List<String>,  // Error messages
  'warnings': List<String>, // Warning messages
  'checks': Map<String, bool> // Individual check results
}
```

**Checks Performed**:
- sing-box.exe existence and functionality
- wintun.dll availability (Windows)
- TUN adapter creation capability
- Configuration template loading
- Administrator privileges

---

### ServerRepository API

Server configuration persistence and management.

#### Methods

##### `Future<List<Server>> loadServers()`
Load server configurations from storage.

**Returns**: List of server configurations

**Source**: `assets/servers.json`

**Throws**:
- `FileSystemException` if file cannot be read
- `FormatException` if JSON is invalid

##### `Future<void> saveServers(List<Server> servers)`
Save server configurations to storage.

**Parameters**:
- `servers`: List of servers to save

**Destination**: `assets/servers.json`

**Side Effects**:
- Overwrites existing configuration file
- Creates backup of previous configuration

---

### Server Model API

Server configuration data model.

#### Constructor
```dart
Server({
  required String name,
  required String address,
  required int port,
  required String id,
  required String pbk,
  required String sni,
  required String sid,
  required String fp,
  bool isBuiltIn = false,
})
```

#### Properties

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `name` | `String` | Display name | Yes |
| `address` | `String` | Server hostname/IP | Yes |
| `port` | `int` | Server port (1-65535) | Yes |
| `id` | `String` | VLESS UUID | Yes |
| `pbk` | `String` | Public key | Yes |
| `sni` | `String` | Server Name Indication | Yes |
| `sid` | `String` | Short ID | Yes |
| `fp` | `String` | Fingerprint | Yes |
| `isBuiltIn` | `bool` | Protected server flag | No (default: false) |

#### Methods

##### `Map<String, dynamic> toJson()`
Convert server to JSON representation.

**Returns**: JSON-serializable map

##### `Server.fromJson(Map<String, dynamic> json)`
Create server from JSON data.

**Parameters**:
- `json`: JSON map with server data

**Returns**: Server instance

**Throws**:
- `ArgumentException` for missing required fields

##### `Server copyWith({...})`
Create a copy with modified properties.

**Parameters**: Named parameters for properties to change

**Returns**: New Server instance

---

## Error Handling

### Exception Types

#### `VpnException`
Base exception for VPN-related errors.

```dart
class VpnException implements Exception {
  final String message;
  final String? details;
  
  VpnException(this.message, [this.details]);
}
```

#### `ConnectionException extends VpnException`
VPN connection establishment errors.

#### `ConfigurationException extends VpnException`
Server configuration validation errors.

#### `SystemException extends VpnException`
System-level integration errors.

### Error Codes

| Code | Description | Recovery |
|------|-------------|----------|
| `VPN_001` | sing-box not found | Install sing-box.exe |
| `VPN_002` | Wintun not available | Install wintun.dll |
| `VPN_003` | No admin privileges | Run as administrator |
| `VPN_004` | Invalid configuration | Check server settings |
| `VPN_005` | Connection timeout | Retry or change server |
| `VPN_006` | Process start failure | Check system resources |

## Events and Callbacks

### VpnProvider Events

Events are broadcast via `ChangeNotifier` pattern:

```dart
provider.addListener(() {
  switch (provider.status) {
    case 'Подключение...':
      onConnecting();
      break;
    case 'Подключено':
      onConnected();
      break;
    case 'Ошибка':
      onError(provider.logOutput);
      break;
    case 'Отключено':
      onDisconnected();
      break;
  }
});
```

### Process Events

Monitor sing-box process events:

```dart
process.stdout.transform(utf8.decoder).listen((data) {
  onProcessOutput(data);
});

process.stderr.transform(utf8.decoder).listen((data) {
  onProcessError(data);
});

process.exitCode.then((code) {
  onProcessExit(code);
});
```

## Configuration API

### Template System

Configuration templates use Mustache-style placeholders:

```json
{
  "outbounds": [
    {
      "type": "vless",
      "server": "{{address}}",
      "server_port": {{port}},
      "uuid": "{{id}}",
      "tls": {
        "enabled": true,
        "server_name": "{{sni}}",
        "reality": {
          "enabled": true,
          "public_key": "{{pbk}}",
          "short_id": "{{sid}}"
        },
        "utls": {
          "enabled": true,
          "fingerprint": "{{fp}}"
        }
      }
    }
  ]
}
```

### Validation Rules

Server configuration validation:

```dart
class ServerValidator {
  static void validate(Server server) {
    if (server.name.isEmpty) {
      throw ConfigurationException('Server name cannot be empty');
    }
    
    if (server.port < 1 || server.port > 65535) {
      throw ConfigurationException('Invalid port range');
    }
    
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(server.id)) {
      throw ConfigurationException('Invalid UUID format');
    }
    
    // Additional validation rules...
  }
}
```

## Testing APIs

### Mock Implementations

For testing, use mock implementations:

```dart
class MockVpnEngine implements VpnEngine {
  @override
  Future<bool> checkFiles() async => true;
  
  @override
  Future<Process> startSingBox() async => MockProcess();
  
  // ... other mock implementations
}
```

### Test Utilities

```dart
class TestUtils {
  static Server createTestServer() {
    return Server(
      name: 'Test Server',
      address: 'test.example.com',
      port: 443,
      id: '12345678-1234-1234-1234-123456789abc',
      pbk: 'test-public-key',
      sni: 'test.example.com',
      sid: 'test-sid',
      fp: 'chrome',
    );
  }
  
  static VpnProvider createTestProvider() {
    return VpnProvider(
      repository: MockServerRepository(),
      engine: MockVpnEngine(),
    );
  }
}
```

## Platform-Specific APIs

### Windows Integration

#### TUN Adapter Management
```dart
// FFI bindings for Wintun
final lib = DynamicLibrary.open('wintun.dll');

final openAdapter = lib.lookupFunction<
  Pointer<Void> Function(Pointer<Utf16>),
  Pointer<Void> Function(Pointer<Utf16>)>('WintunOpenAdapter');

final createAdapter = lib.lookupFunction<
  Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>),
  Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Void>)>('WintunCreateAdapter');
```

#### Process Management
```dart
// Windows-specific process handling
if (Platform.isWindows) {
  // Use Windows job objects for process management
  final job = CreateJobObject(nullptr, nullptr);
  AssignProcessToJobObject(job, process.pid);
}
```

### Future Platform Support

#### Linux
```dart
// Linux TUN interface management
if (Platform.isLinux) {
  await Process.run('ip', ['tun', 'add', 'mode', 'tun', 'name', 'xvpn0']);
  await Process.run('ip', ['addr', 'add', '172.19.0.1/30', 'dev', 'xvpn0']);
}
```

#### macOS
```dart
// macOS network extension integration
if (Platform.isMacOS) {
  // Use Network Extension framework
  final provider = NETunnelProviderManager();
  await provider.loadFromPreferences();
}
```

## Versioning and Compatibility

### API Versioning
- **Major Version**: Breaking changes to public APIs
- **Minor Version**: New features, backward compatible
- **Patch Version**: Bug fixes, no API changes

### Compatibility Matrix

| XVPN Version | Flutter SDK | sing-box | Wintun |
|--------------|-------------|----------|--------|
| 1.2.x | ≥3.16.0 | ≥1.10.0 | ≥0.14.1 |
| 1.1.x | ≥3.10.0 | ≥1.8.0 | ≥0.14.0 |
| 1.0.x | ≥2.17.0 | ≥1.5.0 | ≥0.13.0 |

### Migration Guide

When updating APIs, provide migration examples:

```dart
// v1.1 (deprecated)
await engine.writeConfig(server);

// v1.2 (current)
await engine.generateConfig(server);
```
