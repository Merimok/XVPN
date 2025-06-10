# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2025-06-10

### Fixed
- Fixed syntax error in server_repository_test.dart (missing bracket)
- Replaced deprecated `foregroundColor` with `TextStyle` in ActionChip for Flutter 3.16 compatibility
- Improved FakeProcess implementation in widget_test.dart with proper StreamController handling
- Added proper color styling for ActionChip icons and labels
- Resolved all compilation errors in test suite

### Technical
- Ensured full compatibility with Flutter 3.16.0
- Fixed CI/CD pipeline build failures
- Improved code robustness and error handling

## [1.2.0] - 2025-06-10

### Added
- Comprehensive system diagnostics with detailed error reporting
- Built-in test server "Tannim-DE" for easy setup
- Copy button for logs with clipboard functionality
- Selectable text in log output
- Enhanced file readiness checks
- Detailed TUN adapter diagnostics
- Process lifecycle monitoring with async status updates

### Fixed
- Fixed sing-box command from `[-c]` to `[run, -c]` for proper startup
- Replaced invalid `isCompleted` check with timeout-based approach
- Fixed TUN configuration compatibility with sing-box 1.10+
- Improved VPN connection process management
- Enhanced error handling in connection flow

### Changed
- Updated TUN config from `inet4_address` to `address` array
- Improved process monitoring with non-blocking exitCode checking
- Enhanced UI feedback for missing dependencies
- Better error messages with installation instructions

## [1.1.0] - 2025-06-09

### Added
- Built-in server management system
- `isBuiltIn` field to Server model to prevent deletion of test servers
- Warning messages for missing required files
- Enhanced button state management based on file availability

### Fixed
- Windows compilation errors with const Duration constructor
- Fixed `generateConfig` method signature for proper const handling
- Corrected sing-box test command from `--test` to `version`

### Security
- Added .gitignore rules to exclude binary files from version control
- Improved handling of sensitive server configurations

## [1.0.0] - 2025-06-08

### Added
- Initial release of XVPN Flutter VPN client
- VLESS protocol support via sing-box integration
- Windows native TUN adapter support with Wintun
- Material Design UI with connection management
- Server configuration management (add/edit/delete servers)
- Real-time connection status monitoring
- Comprehensive logging system
- Ping functionality for server testing
- Configuration template system for sing-box
- Unit tests for core components

### Features
- **VPN Engine**: Complete sing-box process management
- **UI Components**: Modern Material Design interface
- **Server Management**: JSON-based server configuration storage
- **Diagnostics**: System readiness checks and error reporting
- **Cross-platform**: Built with Flutter for future platform expansion

### Technical
- Provider pattern for state management
- Repository pattern for data access
- FFI integration for Windows-specific functionality
- Async process monitoring and error handling

### Dependencies
- Flutter SDK ≥2.17.0
- sing-box (external binary)
- Wintun driver for Windows TUN support
- Provider package for state management
- Path utilities for file management

---

## Release Notes

### Version 1.2.0 Highlights
This release focuses on improving the VPN connection reliability and user experience:

- **Enhanced Diagnostics**: The new diagnostics system provides comprehensive checks for all required components with detailed error messages and installation instructions.
- **Better Process Management**: Fixed critical issues with sing-box process lifecycle management that were causing connection problems.
- **Improved UI/UX**: Added clipboard functionality and better visual feedback for system status.

### Known Issues
- VPN traffic routing may require additional Windows routing table configuration
- Some antivirus software may flag the application due to TUN adapter usage
- Administrator privileges are required for TUN adapter creation

### Upgrade Notes
- No breaking changes in this release
- Existing server configurations remain compatible
- Binary dependencies (sing-box.exe, wintun.dll) should be updated to latest versions

### Future Roadmap
- [ ] Linux support
- [ ] macOS support  
- [ ] Built-in server discovery
- [ ] Advanced routing configuration
- [ ] Connection profiles and automation
- [ ] Traffic statistics and monitoring
- [ ] Multiple simultaneous connections
- [ ] Plugin system for protocol extensions
