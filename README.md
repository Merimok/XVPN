# XVPN

This repository contains a prototype Flutter-based VLESS VPN client for Windows.

The project resides in `vpn_client/`.

Two sample VLESS servers are preloaded in `assets/servers.json`. They can be selected from the dropdown when the app starts.

When adding a new server, you can either fill the details manually or paste a full
`vless://` URL into the provided field and it will be parsed automatically.

The client relies on `sing-box.exe`, `wintun.dll`, and a ready `config.json` placed next to the compiled `vpn_client.exe`.
If the TUN interface fails to start, try launching the application as Administrator.

Run the app with Flutter:

```bash
cd vpn_client
flutter pub get
flutter create . --platforms=windows
flutter run -d windows
```

A GitHub Actions workflow builds the Windows release on pushes.

