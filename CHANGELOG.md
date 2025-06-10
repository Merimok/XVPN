# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.9] - 2025-06-10

### Fixed
- **Flutter Windows Build**: Fixed missing vpn_client.exe generation in GitHub Actions
- **Windows Platform**: Added proper Windows platform structure to enable builds
- **CI/CD Flutter Integration**: Enhanced workflows with verbose Flutter build logging
- **Build Diagnostics**: Added comprehensive Flutter build verification and error reporting

### Improved
- **Build Process**: Added Windows platform creation step in CI/CD workflows
- **Error Detection**: Enhanced build failure diagnosis with detailed file system checks
- **Workflow Reliability**: Improved Flutter build process with proper platform setup
- **Debug Information**: Added verbose build output for troubleshooting CI/CD issues

### Technical
- **Windows Directory**: Created basic windows/ platform structure with CMakeLists.txt
- **Flutter Create**: Added automatic Windows platform generation in workflows
- **Build Verification**: Added checks for vpn_client.exe creation and file sizes
- **Platform Detection**: Enhanced logic for Windows platform setup in CI/CD

## [1.2.8] - 2025-06-10

### Fixed
- **CI/CD Directory Creation**: Fixed "The system cannot find the path specified" errors by ensuring Release directory exists before copying files
- **Windows Build Path Issues**: Enhanced directory structure creation with step-by-step verification
- **File Copy Operations**: Improved robustness of copying sing-box.exe and wintun.dll to Release folder
- **Build Process Reliability**: Added comprehensive diagnostic output and error handling

### Improved
- **CI/CD Debugging**: Added detailed logging and verification steps in GitHub Actions workflows
- **Error Diagnostics**: Enhanced error messages with directory structure validation
- **Build Automation**: More robust file copy operations with forced directory creation
- **Workflow Stability**: Improved reliability of both build_windows.yml and release.yml workflows

### Technical
- **Directory Validation**: Added checks for build\windows\runner\Release\ directory existence
- **Copy Command Enhancement**: Using copy /Y for overwrite protection and better error handling
- **Build Structure**: Ensuring complete directory tree creation before file operations

## [1.2.7] - 2025-06-10

### Fixed
- **CI/CD File Detection**: Enhanced GitHub Actions workflows with better error checking and debugging
- **Download Verification**: Added file size verification and existence checks before copying
- **Error Handling**: Improved error messages and debugging output for CI/CD failures
- **Path Resolution**: Fixed file path issues in Windows build commands

### Improved
- **Build Reliability**: Enhanced workflow stability with detailed logging and error detection
- **Debugging Output**: Added comprehensive logging for troubleshooting CI/CD issues
- **Error Recovery**: Better error handling and informative failure messages

## [1.2.6] - 2025-06-10

### Fixed
- **CI/CD Pipeline**: Fixed GitHub Actions build failures due to missing dependencies
- **Automatic Downloads**: Added automatic downloading of sing-box.exe and wintun.dll during build process
- **File Copying**: Fixed incorrect paths in Windows build commands that caused "path not found" errors
- **Release Automation**: Enhanced release workflow to create complete, ready-to-use ZIP packages

### Improved
- **Build Process**: Fully automated dependency management - no manual file placement required
- **Release Quality**: GitHub Releases now contain all necessary files for end-user deployment
- **CI/CD Reliability**: Robust error handling and proper file structure in build artifacts
- **Documentation**: Added comprehensive CI/CD guide with troubleshooting instructions

### Technical
- **Workflow Updates**: Updated build_windows.yml and release.yml with proper dependency management
- **File Structure**: Automated copying of sing-box.exe and wintun.dll to release folders
- **Error Prevention**: Fixed "The system cannot find the path specified" build errors

## [1.2.5] - 2025-06-10

### Fixed
- **VpnProvider Compilation Error**: Fixed undefined `processRunning` variable that caused build failures
- **Connection State Management**: Added proper `_isConnected` boolean flag for tracking VPN connection status
- **Process State Tracking**: Enhanced connection state management with correct variable declarations

### Improved
- **State Management**: Added `isConnected` getter for cleaner access to connection status
- **Error Handling**: Improved disconnect method to properly reset connection state
- **Code Reliability**: Eliminated undefined identifier errors in VpnProvider

## [1.2.4] - 2025-06-10

### Fixed
- **Critical Build Issues**: Resolved all 41 compilation errors and warnings that prevented successful builds
- **Deprecated API Usage**: Updated all `surfaceVariant` references to `surfaceContainerHighest` for Material 3 compatibility
- **Syntax Errors**: Fixed malformed main.dart structure that caused build failures
- **Unused Code**: Cleaned up unused imports, variables, and functions with appropriate ignore directives

### Improved  
- **Code Quality**: Achieved zero compilation errors and warnings for production readiness
- **Material 3 Compliance**: Updated theme system to use latest Material 3 color properties
- **Build Reliability**: Enhanced CI/CD pipeline stability with error-free compilation

### Technical
- Fixed undefined named parameter errors in MaterialApp configuration
- Resolved import conflicts and unnecessary dependencies
- Added proper ignore directives for legacy code elements
- Enhanced error handling and code organization

This release ensures the application compiles and runs without any errors while maintaining all the modern Mullvad-style design features from v1.2.3.

## [1.2.3] - 2025-06-10

### Added
- **New Mullvad-Style Design**: Complete redesign with modern Material 3 theme
  - Custom Mullvad-inspired color scheme with deep purple gradients (#5E4EBD, #7B68EE, #44337A)
  - Animated hero sections with pulse and slide effects for connection states
  - Modern card designs with subtle borders and elevated shadows
  - Custom component library (`MullvadCard`, `MullvadActionButton`, `StatusCard`, `ServerTile`)
  - Animated connection status icons with rotation and pulse animations
- **Enhanced Settings Screen**: Updated settings to match new Mullvad design language
  - Modern section headers with gradient icons
  - Consistent spacing and typography throughout
  - Improved visual hierarchy and interaction feedback

### Changed
- **Home Screen**: Replaced original design with Mullvad-inspired interface
  - Hero sections with modern gradients and animations
  - Improved layout and spacing for better visual balance
  - Enhanced server selection with modern dropdown design
  - Better visual feedback for all user interactions
- **Application Theme**: Updated to modern Material 3 with custom color scheme
  - Professional purple color palette inspired by Mullvad VPN
  - Consistent typography using Inter font family
  - Improved dark theme support with proper contrast ratios

### Improved
- **Design Consistency**: Unified design language across all screens
- **User Experience**: Better visual feedback and intuitive interactions
- **Accessibility**: Improved contrast ratios and touch target sizes
- **Animation System**: Smooth transitions and state change animations

### Technical
- Created `mullvad_widgets.dart` component library for reusable UI elements
- Maintained backward compatibility by preserving original design as `home_screen_old.dart`
- Enhanced theme configuration with proper Material 3 color schemes
- Improved widget organization and code structure

## [1.2.2] - 2025-06-10

### Fixed
- **Server Addition Bug**: Fixed critical issue where newly added VLESS servers weren't appearing in the server list
- **Operation Feedback**: Improved success/error feedback mechanism for server operations
- **Error Handling**: Added proper rollback if server save operation fails

### Improved
- **Compact UI Design**: Significantly reduced spacing and element sizes throughout the application
  - Reduced main padding from 20px to 12px
  - Compressed connection status card padding from 24px to 16px
  - Reduced main connection button height from 56px to 48px
  - Decreased logs area height from 200px to 150px
  - Made ActionChips smaller with 16px icons and 12px font
  - Compressed statistics cards with smaller padding and icons
  - Added `dense: true` to all ListTiles in settings for better space utilization
- **Visual Polish**: Reduced border radius and shadow effects for cleaner appearance
- **Settings Screen**: Made all settings more compact with reduced spacing

### Technical
- Added `lastOperationResult` mechanism to `VpnProvider` for better operation tracking
- Enhanced error handling and rollback logic in `addServer` method
- Improved separation of concerns for UI feedback
- Better state management for server operations

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
