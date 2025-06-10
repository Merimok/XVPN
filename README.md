# XVPN

This repository contains a Flutter based VLESS VPN client targeting Windows desktop. The application is located under `vpn_client/`.

## Building on Windows

```bash
cd vpn_client
flutter pub get
flutter create . --platforms=windows
flutter run -d windows
```

Place `sing-box.exe`, `config.json` and `wintun.dll` next to the compiled `vpn_client.exe` (usually in `build/windows/runner/Release/`).
To install Wintun driver run `install-driver.bat` from the official Wintun package and check the service with `sc query wintun`.

## Security recommendations

- Consider encrypting `servers.json` with packages like `flutter_secure_storage`.
- Keep UUIDs and public keys safe and do not expose them publicly.
