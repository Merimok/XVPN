# XVPN - Flutter VLESS VPN Client

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

A modern, lightweight VLESS VPN client built with Flutter for Windows desktop. Features a clean Material Design interface with comprehensive diagnostics and built-in server management.

## 🌟 Features

- **VLESS Protocol Support** - Full VLESS proxy protocol implementation
- **Windows Native Integration** - TUN adapter support via Wintun
- **Built-in Diagnostics** - Comprehensive system readiness checks
- **Server Management** - Add, edit, and manage multiple VPN servers
- **Real-time Monitoring** - Live connection status and process monitoring
- **Material Design UI** - Clean, modern interface with dark/light theme support
- **Detailed Logging** - Full connection logs with copy functionality
- **Built-in Test Server** - Pre-configured server for testing

## 📋 Requirements

### System Requirements
- **OS**: Windows 10/11 (64-bit)
- **RAM**: 4GB minimum
- **Storage**: 100MB free space
- **Network**: Internet connection

### Dependencies
- **sing-box** - Core VPN engine (automatically managed)
- **Wintun** - Windows TUN adapter driver
- **Administrator Rights** - Required for TUN adapter creation

## 🚀 Quick Start

### 1. Download Release
Download the latest release from [GitHub Releases](https://github.com/your-username/XVPN/releases)

### 2. Install Dependencies
The application will guide you through installing required dependencies:
- `sing-box.exe` - VPN engine
- `wintun.dll` - TUN adapter library

### 3. Run as Administrator
Right-click `vpn_client.exe` → "Run as administrator"

### 4. System Check
Click "Диагностика" to verify system readiness

### 5. Connect
Select a server and click "Подключиться"

## 🛠️ Building from Source

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥3.0.0)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) with C++ tools
- [Git](https://git-scm.com/)

### Build Steps

```bash
# Clone repository
git clone https://github.com/your-username/XVPN.git
cd XVPN/vpn_client

# Install dependencies
flutter pub get

# Create Windows platform files (if needed)
flutter create . --platforms=windows

# Build for Windows
flutter build windows --release
```

### Development Mode
```bash
# Run in debug mode
flutter run -d windows

# Hot reload available for UI changes
```

## 📁 Project Structure

```
XVPN/
├── vpn_client/                 # Main Flutter application
│   ├── lib/
│   │   ├── main.dart          # Application entry point
│   │   ├── models/            # Data models
│   │   │   └── server.dart    # Server configuration model
│   │   ├── screens/           # UI screens
│   │   │   └── home_screen.dart
│   │   ├── services/          # Business logic
│   │   │   ├── server_repository.dart
│   │   │   └── vpn_engine.dart # Core VPN engine
│   │   └── state/             # State management
│   │       └── vpn_provider.dart
│   ├── assets/
│   │   └── servers.json       # Server configurations
│   ├── sing-box/              # VPN engine resources
│   │   ├── config_template.json
│   │   ├── sing-box.exe       # Downloaded separately
│   │   └── wintun.dll         # Downloaded separately
│   └── test/                  # Unit tests
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## ⚙️ Configuration

### Server Configuration
Edit `assets/servers.json` to add your VLESS servers:

```json
[
  {
    "name": "My Server",
    "address": "your-server.com",
    "port": 443,
    "id": "your-uuid-here",
    "pbk": "your-public-key",
    "sni": "your-server.com",
    "sid": "your-short-id",
    "fp": "chrome",
    "isBuiltIn": false
  }
]
```

### sing-box Template
The VPN configuration is generated from `sing-box/config_template.json` with placeholder replacement.

## 🔧 Troubleshooting

### Common Issues

**"sing-box.exe не найден"**
- Download sing-box from [official releases](https://github.com/SagerNet/sing-box/releases)
- Place `sing-box.exe` in the same folder as `vpn_client.exe`

**"wintun.dll не найден"**
- Download Wintun from [official site](https://www.wintun.net/)
- Extract `wintun.dll` from `bin/amd64/` folder
- Place next to `vpn_client.exe`

**"Требуются права администратора"**
- Right-click application → "Run as administrator"
- Required for TUN adapter creation

**Connection shows "Connected" but no internet**
- Check sing-box logs in the application
- Verify server configuration
- Ensure proper routing setup

### Debug Mode
1. Enable detailed logging in settings
2. Use "Диагностика" for system checks
3. Copy logs using the copy button
4. Check Windows Event Viewer for system-level errors

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/vpn_engine_test.dart
flutter test test/server_test.dart
```

### Test Coverage
- Unit tests for all core components
- Integration tests for VPN engine
- UI widget tests

## 🏗️ Architecture

### Design Patterns
- **Provider Pattern** - State management with `provider` package
- **Repository Pattern** - Data access abstraction
- **Service Layer** - Business logic separation

### Key Components

**VpnEngine** (`lib/services/vpn_engine.dart`)
- Core VPN functionality
- sing-box process management
- System diagnostics
- TUN adapter handling

**VpnProvider** (`lib/state/vpn_provider.dart`)
- Application state management
- Connection lifecycle
- Error handling
- UI notifications

**ServerRepository** (`lib/services/server_repository.dart`)
- Server configuration management
- JSON serialization/deserialization
- Built-in server handling

## 🔒 Security

### Best Practices Implemented
- No hardcoded credentials
- Secure server configuration storage
- Process isolation
- Administrator privilege validation

### Recommendations
- Use `flutter_secure_storage` for sensitive data
- Implement certificate pinning for server connections
- Regular security audits of dependencies
- Monitor for unusual network activity

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass: `flutter test`
6. Commit changes: `git commit -m 'Add amazing feature'`
7. Push to branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Add documentation for public APIs
- Write meaningful commit messages

### Bug Reports
When reporting bugs, include:
- OS version and architecture
- Flutter version
- Application version
- Steps to reproduce
- Error logs from diagnostics

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [sing-box](https://github.com/SagerNet/sing-box) - Powerful VPN engine
- [Wintun](https://www.wintun.net/) - Windows TUN adapter
- [Flutter](https://flutter.dev/) - Cross-platform UI framework
- VLESS Protocol developers

## 📞 Support

- 📫 **Issues**: [GitHub Issues](https://github.com/your-username/XVPN/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-username/XVPN/discussions)
- 📖 **Wiki**: [Project Wiki](https://github.com/your-username/XVPN/wiki)

---

**⚠️ Legal Notice**: This software is provided for educational and legitimate use only. Users are responsible for complying with all applicable laws and regulations in their jurisdiction. The developers assume no responsibility for misuse of this software.
