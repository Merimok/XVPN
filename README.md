# XVPN

This repository contains a prototype Flutter-based VLESS VPN client for Windows.

The project resides in `vpn_client/`.

Two sample VLESS servers are preloaded in `assets/servers.json`. They can be selected from the dropdown when the app starts.

Run the app with Flutter:

```bash
cd vpn_client
flutter pub get
flutter create . --platforms=windows
flutter run -d windows
```

This project targets Windows 11 and does not require Android builds.

