# XVPN Architecture Documentation

## Overview

XVPN is a Flutter-based VLESS VPN client designed for Windows desktop. The architecture follows modern Flutter patterns with clear separation of concerns and maintainable code structure.

## Architecture Patterns

### 1. Provider Pattern (State Management)
```dart
VpnProvider extends ChangeNotifier
├── Connection state management
├── Server configuration handling
├── Process lifecycle monitoring
└── UI state synchronization
```

### 2. Repository Pattern (Data Access)
```dart
ServerRepository
├── JSON file operations
├── Server configuration persistence
├── Data validation
└── Error handling
```

### 3. Service Layer (Business Logic)
```dart
VpnEngine
├── sing-box process management
├── System diagnostics
├── TUN adapter handling
└── Configuration generation
```

## Component Hierarchy

```
┌─────────────────┐
│   Flutter App   │
├─────────────────┤
│   Home Screen   │
├─────────────────┤
│   VpnProvider   │
├─────────────────┤
│ ┌─────────────┐ │
│ │VpnEngine    │ │
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ServerRepo   │ │
│ └─────────────┘ │
├─────────────────┤
│   sing-box      │
│   (External)    │
└─────────────────┘
```

## Core Components

### VpnProvider (`lib/state/vpn_provider.dart`)
**Responsibility**: Application state management and business logic coordination

**Key Methods**:
- `init()` - Initialize application state
- `connect()` - Establish VPN connection
- `disconnect()` - Terminate VPN connection
- `runDiagnostics()` - System health checks
- `addServer()` / `removeServer()` - Server management

**State Properties**:
```dart
List<Server> servers        // Available servers
Server? selected           // Currently selected server
String status             // Connection status
String logOutput          // Application logs
bool filesReady           // System readiness
```

### VpnEngine (`lib/services/vpn_engine.dart`)
**Responsibility**: Core VPN functionality and system integration

**Key Methods**:
- `startSingBox()` - Launch VPN process
- `generateConfig()` - Create sing-box configuration
- `ensureTunAdapter()` - Setup Windows TUN adapter
- `diagnoseSystem()` - Comprehensive system checks
- `checkFiles()` - Verify required binaries

**File Management**:
```dart
String get singBoxPath    // Path to sing-box.exe
String get configPath     // Generated configuration
String get wintunPath     // Path to wintun.dll
```

### ServerRepository (`lib/services/server_repository.dart`)
**Responsibility**: Server configuration persistence and management

**Key Methods**:
- `loadServers()` - Load from JSON file
- `saveServers()` - Persist to JSON file
- `validateServer()` - Configuration validation

### Server Model (`lib/models/server.dart`)
**Responsibility**: Server configuration data structure

**Properties**:
```dart
String name              // Display name
String address           // Server hostname/IP
int port                 // Server port
String id                // VLESS UUID
String pbk               // Public key
String sni               // Server Name Indication
String sid               // Short ID
String fp                // Fingerprint
bool isBuiltIn           // Protected server flag
```

## Data Flow

### Connection Establishment
```
User clicks "Connect"
       ↓
VpnProvider.connect()
       ↓
VpnEngine.generateConfig()
       ↓
VpnEngine.startSingBox()
       ↓
Process monitoring
       ↓
Status updates via Provider
       ↓
UI reflects connection state
```

### Configuration Management
```
Load servers.json
       ↓
ServerRepository.loadServers()
       ↓
Parse JSON to Server objects
       ↓
VpnProvider.servers list
       ↓
UI displays server list
```

## External Dependencies

### sing-box Integration
- **Process Management**: Started as separate process
- **Configuration**: JSON template with placeholder replacement
- **Commands**: `version`, `check`, `run -c config.json`
- **Monitoring**: stdout/stderr streams + exit code

### Wintun Integration
- **FFI Binding**: Direct DLL function calls
- **Adapter Management**: Create/open TUN adapter
- **Functions Used**: `WintunOpenAdapter`, `WintunCreateAdapter`

## Error Handling Strategy

### Layered Error Handling
1. **System Level**: File system, process, network errors
2. **Application Level**: Configuration, validation errors
3. **UI Level**: User-friendly error messages

### Error Propagation
```
System Error
    ↓
Service Layer (VpnEngine)
    ↓
State Layer (VpnProvider)
    ↓
UI Layer (Error display)
```

### Error Types
- **FileSystemException**: Missing binaries
- **ProcessException**: sing-box execution errors
- **ValidationException**: Configuration errors
- **NetworkException**: Connection failures

## Threading Model

### Main Thread
- UI rendering
- State management
- User interactions

### Background Processing
- File I/O operations
- Process monitoring
- Network requests

### Async/Await Pattern
```dart
Future<void> connect() async {
  // Non-blocking operations
  await generateConfig();
  await startSingBox();
  // UI updates on main thread
  notifyListeners();
}
```

## Configuration System

### Template-Based Configuration
sing-box configuration generated from template:
```json
{
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": ["172.19.0.1/30"],
      "auto_route": true
    }
  ],
  "outbounds": [
    {
      "type": "vless",
      "server": "{{address}}",
      "server_port": {{port}},
      "uuid": "{{id}}"
      // ... more VLESS configuration
    }
  ]
}
```

### Placeholder Replacement
Template placeholders replaced with server values:
- `{{address}}` → server.address
- `{{port}}` → server.port.toString()
- `{{id}}` → server.id
- etc.

## Security Considerations

### Privilege Management
- Administrator rights required only for TUN adapter
- Process runs with minimal necessary privileges
- Configuration files protected with appropriate permissions

### Data Protection
- Server configurations stored in plain JSON (consider encryption)
- No credentials stored in application code
- Sensitive data cleared from memory when possible

### Network Security
- TLS certificate validation in VLESS connections
- DNS leak prevention via TUN routing
- Traffic isolated through VPN tunnel

## Performance Considerations

### Resource Usage
- Minimal memory footprint for Flutter UI
- sing-box handles network processing
- Efficient state management with Provider

### Process Management
- Proper cleanup of sing-box processes
- Resource leak prevention
- Graceful shutdown handling

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Business logic validation
- Error handling scenarios

### Integration Tests
- VPN engine functionality
- File system operations
- Process lifecycle management

### Widget Tests
- UI component behavior
- State management integration
- User interaction flows

## Future Architecture Improvements

### Planned Enhancements
1. **Plugin Architecture**: Extensible protocol support
2. **Configuration Encryption**: Secure storage of sensitive data
3. **Multi-platform Support**: Linux and macOS compatibility
4. **Advanced Routing**: Custom routing table management
5. **Connection Profiles**: Saved connection configurations

### Scalability Considerations
- Modular component design
- Loose coupling between layers
- Extensible configuration system
- Platform abstraction layers

## Development Guidelines

### Code Organization
```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
├── screens/              # UI screens
├── services/             # Business logic
├── state/                # State management
└── utils/                # Helper utilities
```

### Naming Conventions
- Classes: PascalCase (`VpnProvider`)
- Methods: camelCase (`generateConfig`)
- Constants: UPPER_SNAKE_CASE (`DEFAULT_PORT`)
- Files: snake_case (`vpn_engine.dart`)

### Documentation Standards
- Public APIs must have dartdoc comments
- Complex business logic requires inline comments
- Architecture decisions documented in ADR format
