# Deployment Guide

This guide covers deployment strategies for XVPN across different environments.

## Build Environments

### Development Build
```bash
cd vpn_client
flutter pub get
flutter run -d windows
```

**Characteristics**:
- Debug symbols included
- Hot reload enabled
- Development paths for binaries
- Console output available

### Release Build
```bash
cd vpn_client
flutter build windows --release
```

**Output Location**: `build/windows/runner/Release/`

**Characteristics**:
- Optimized for performance
- Minimal size
- No debug information
- Production paths for binaries

### CI/CD Build
Automated via GitHub Actions (see `.github/workflows/build.yml`)

**Process**:
1. Checkout code
2. Setup Flutter environment  
3. Run tests and analysis
4. Build release version
5. Create artifacts
6. Upload to releases

## Binary Dependencies

### Required Files
The application requires these external binaries:

#### sing-box.exe
- **Source**: [SagerNet/sing-box releases](https://github.com/SagerNet/sing-box/releases)
- **Version**: Latest stable (recommend 1.10+)
- **File**: `sing-box-{version}-windows-amd64.exe`
- **Rename to**: `sing-box.exe`
- **Location**: Same directory as `vpn_client.exe`

#### wintun.dll
- **Source**: [WireGuard Wintun](https://www.wintun.net/)
- **Version**: Latest stable
- **File**: `bin/amd64/wintun.dll` from archive
- **Location**: Same directory as `vpn_client.exe`

### Automated Download Script
Create `download-deps.ps1`:
```powershell
# Download and setup dependencies
$ErrorActionPreference = "Stop"

$buildDir = "build\windows\runner\Release"
if (!(Test-Path $buildDir)) {
    Write-Error "Build directory not found. Run 'flutter build windows --release' first."
}

# Download sing-box
$singboxUrl = "https://github.com/SagerNet/sing-box/releases/latest/download/sing-box-windows-amd64.exe"
$singboxPath = "$buildDir\sing-box.exe"
Write-Host "Downloading sing-box..."
Invoke-WebRequest -Uri $singboxUrl -OutFile $singboxPath

# Download Wintun
$wintunUrl = "https://www.wintun.net/builds/wintun-0.14.1.zip"
$wintunZip = "$env:TEMP\wintun.zip"
$wintunExtract = "$env:TEMP\wintun"
Write-Host "Downloading Wintun..."
Invoke-WebRequest -Uri $wintunUrl -OutFile $wintunZip
Expand-Archive -Path $wintunZip -DestinationPath $wintunExtract -Force
Copy-Item "$wintunExtract\wintun\bin\amd64\wintun.dll" "$buildDir\"

# Cleanup
Remove-Item $wintunZip
Remove-Item $wintunExtract -Recurse

Write-Host "Dependencies downloaded successfully!"
```

## Deployment Strategies

### 1. Standalone Executable

**Structure**:
```
XVPN-Release/
├── vpn_client.exe
├── sing-box.exe
├── wintun.dll
├── README.txt
└── data/
    └── flutter_assets/
```

**Advantages**:
- Simple distribution
- No installation required
- Portable

**Disadvantages**:
- Large file size
- Manual dependency management

### 2. Installer Package

Using tools like Inno Setup or NSIS:

**Features**:
- Automatic dependency download
- Start menu shortcuts
- Uninstaller
- System requirements check
- Administrator privilege request
- Windows Defender exclusions

**Example Inno Setup Script**:
```inno
[Setup]
AppName=XVPN
AppVersion=1.2.0
DefaultDirName={autopf}\XVPN
DefaultGroupName=XVPN
UninstallDisplayIcon={app}\vpn_client.exe
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\XVPN"; Filename: "{app}\vpn_client.exe"
Name: "{group}\Uninstall XVPN"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\download-deps.exe"; Description: "Download dependencies"; Flags: postinstall
```

### 3. Microsoft Store Package

**Requirements**:
- Windows App Certification Kit compliance
- Store certification process
- Restricted capabilities declaration

**Configuration** (`windows/runner/main.cpp`):
```cpp
// Store-compliant configuration
#if WINRT_ENABLED
#include <winrt/base.h>
// Store-specific initialization
#endif
```

### 4. Portable Distribution

**Features**:
- Single directory deployment
- Registry-free operation
- USB drive compatible
- Settings stored locally

**Structure**:
```
XVPN-Portable/
├── XVPN.exe
├── sing-box.exe
├── wintun.dll
├── config/
│   └── servers.json
└── logs/
    └── app.log
```

## Configuration Management

### Production Configuration

**servers.json**:
```json
[
  {
    "name": "Production Server",
    "address": "prod.example.com",
    "port": 443,
    "id": "production-uuid",
    "pbk": "production-key",
    "sni": "prod.example.com",
    "sid": "prod-sid",
    "fp": "chrome",
    "isBuiltIn": false
  }
]
```

### Environment-Specific Builds

**Development**:
```json
{
  "debug": true,
  "logLevel": "verbose",
  "testServers": true
}
```

**Production**:
```json
{
  "debug": false,
  "logLevel": "error",
  "testServers": false
}
```

## Security Deployment

### Code Signing

**Certificate Requirements**:
- Extended Validation (EV) certificate preferred
- Standard code signing certificate minimum
- Valid publisher information

**Signing Process**:
```powershell
# Sign main executable
signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a "vpn_client.exe"

# Sign installer
signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a "XVPN-Setup.exe"
```

### Windows Defender

**SmartScreen Bypass**:
- Code signing reduces warnings
- Reputation building over time
- Microsoft Partner Center submission

**Exclusion Instructions**:
```
Windows Security → Virus & threat protection → 
Manage settings → Add or remove exclusions → 
Add folder: C:\Program Files\XVPN
```

### User Account Control

**Manifest Configuration** (`windows/runner/Runner.exe.manifest`):
```xml
<requestedExecutionLevel
  level="requireAdministrator"
  uiAccess="false" />
```

## Distribution Channels

### 1. GitHub Releases
- Automated via GitHub Actions
- Version tagging triggers release
- Asset upload and description
- Download statistics

### 2. Direct Download
- Host on CDN
- Checksum verification
- Update notifications
- Usage analytics

### 3. Package Managers

**Chocolatey**:
```xml
<package>
  <metadata>
    <id>xvpn</id>
    <version>1.2.0</version>
    <title>XVPN</title>
    <authors>XVPN Team</authors>
    <description>Flutter-based VLESS VPN client</description>
  </metadata>
</package>
```

**winget**:
```yaml
PackageIdentifier: XVPN.XVPN
PackageVersion: 1.2.0
PackageName: XVPN
Publisher: XVPN Team
ShortDescription: VLESS VPN Client
Installers:
  - Architecture: x64
    InstallerType: exe
    InstallerUrl: https://github.com/user/XVPN/releases/download/v1.2.0/XVPN-Setup.exe
```

## Update Management

### Auto-Update System

**Version Check**:
```dart
class UpdateChecker {
  static const String _updateUrl = 'https://api.github.com/repos/user/XVPN/releases/latest';
  
  Future<bool> checkForUpdates() async {
    final response = await http.get(Uri.parse(_updateUrl));
    final release = json.decode(response.body);
    final latestVersion = release['tag_name'];
    return compareVersions(currentVersion, latestVersion);
  }
}
```

**Update Download**:
```dart
Future<void> downloadUpdate(String downloadUrl) async {
  final response = await http.get(Uri.parse(downloadUrl));
  final file = File('XVPN-Update.exe');
  await file.writeAsBytes(response.bodyBytes);
  
  // Verify checksum
  final actualHash = sha256.convert(response.bodyBytes).toString();
  if (actualHash != expectedHash) {
    throw Exception('Update verification failed');
  }
}
```

### Manual Update Process

1. Download new release
2. Close running application
3. Backup configuration
4. Install new version
5. Restore configuration
6. Restart application

## Monitoring and Analytics

### Error Reporting

**Crash Reporting**:
```dart
void main() {
  FlutterError.onError = (details) {
    // Send crash report
    CrashReporter.report(details);
  };
  
  runApp(MyApp());
}
```

**Performance Monitoring**:
```dart
class PerformanceMonitor {
  static void trackConnection(Duration connectTime) {
    Analytics.track('connection_time', {'duration': connectTime.inMilliseconds});
  }
}
```

### Usage Analytics

**Privacy-Compliant Metrics**:
- Connection success/failure rates
- Feature usage statistics
- Performance metrics
- Error frequencies
- No personal data collection

## Rollback Strategy

### Version Rollback

**Automated Rollback**:
1. Detect critical errors
2. Stop current version
3. Restore previous version
4. Notify user of rollback

**Manual Rollback**:
1. Keep previous version backup
2. Restore configuration
3. Reinstall dependencies
4. Update user documentation

### Configuration Rollback

**Settings Backup**:
```dart
class ConfigBackup {
  static Future<void> createBackup() async {
    final config = await ServerRepository.loadServers();
    final backup = File('config.backup.json');
    await backup.writeAsString(json.encode(config));
  }
}
```

## Support and Maintenance

### Support Channels
- GitHub Issues for bug reports
- GitHub Discussions for questions
- Documentation wiki
- Email support for critical issues

### Maintenance Schedule
- **Weekly**: Dependency updates
- **Monthly**: Security patches
- **Quarterly**: Feature releases
- **Annually**: Major version updates

### End-of-Life Policy
- 2 years support for major versions
- 6 months security updates after EOL
- Migration guides for version upgrades
- Clear deprecation notices
