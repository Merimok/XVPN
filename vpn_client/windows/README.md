# Windows Platform Configuration

This directory contains Windows-specific files for the Flutter application.
These files are required for Windows desktop builds.

## Files
- `CMakeLists.txt` - Main CMake configuration
- `runner/` - Windows runner application code
- `flutter/` - Flutter Windows embedder

## Build Process
The Windows platform files will be automatically generated/updated during:
```bash
flutter create --platforms=windows .
flutter build windows --release
```

## Generated Files
When building, Flutter will generate:
- Binary executable: `build/windows/runner/Release/vpn_client.exe`
- Dependencies: System DLLs and Flutter runtime
- Assets: Application resources and data
