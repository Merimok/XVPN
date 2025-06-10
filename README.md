# XVPN

This repository contains a prototype Flutter-based VLESS VPN client for Windows.

The project resides in `vpn_client/`.

Two sample VLESS servers are preloaded in `assets/servers.json`. They can be selected from the dropdown when the app starts.

When adding a new server, you can either fill the details manually or paste a full
`vless://` URL into the provided field and it will be parsed automatically.

The app copies this server list to your application documents directory on first run and persists any changes there. The writable `servers.json` can be found under the path returned by the `path_provider` package.

Run the app with Flutter:

```bash
cd vpn_client
flutter pub get
flutter create . --platforms=windows
flutter run -d windows
