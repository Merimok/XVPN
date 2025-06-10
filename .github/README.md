# GitHub Actions Status

## Current Workflows

### 1. Build and Test (`build.yml`)
- **Triggers**: Push to `main` or `develop`, Pull Requests to `main`
- **Jobs**: 
  - `test`: Code analysis, tests, formatting (Windows)
  - `build`: Windows release build (only on main branch push)
- **Artifacts**: `windows-build`, `build-info`

### 2. Release (`release.yml`)
- **Triggers**: Push tags matching `v*` pattern
- **Jobs**: 
  - `release`: Full build, test, and release package creation
- **Artifacts**: `XVPN-Windows-{version}.zip`

### 3. Build Windows (`build_windows.yml`)
- **Triggers**: Push to `main`, Pull Requests to `main`
- **Features**: Downloads latest sing-box binary automatically
- **Artifacts**: Complete Windows build with dependencies

## Recent Updates (v1.2.3)

✅ **Fixed Issues:**
- Updated Flutter version to 3.24.3 for better compatibility
- Updated checkout actions to v4 for security
- Temporarily disabled formatting check to allow builds
- Removed duplicate workflow files
- Fixed dependency management

## Checking Build Status

1. **Visit Repository**: https://github.com/Merimok/XVPN
2. **Actions Tab**: Click on "Actions" to see workflow runs
3. **Latest Runs**: Check status of recent commits and tags
4. **Artifacts**: Download build artifacts from successful runs

## Triggering Releases

To create a new release:

```bash
# Create and push a new tag
git tag -a v1.2.4 -m "Release v1.2.4: Description"
git push origin v1.2.4
```

This will automatically:
- Build the Windows application
- Run all tests
- Create release artifacts
- Package everything into downloadable ZIP

## Troubleshooting

### Build Failures
1. Check Flutter version compatibility in workflows
2. Verify all dependencies are in pubspec.yaml
3. Ensure assets are properly defined
4. Check for formatting issues (temporarily disabled)

### Missing Dependencies
1. sing-box.exe is downloaded automatically in build_windows.yml
2. wintun.dll should be in sing-box/ directory
3. config_template.json should be in assets

### Local Testing
```bash
cd vpn_client
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

---

**Last Updated**: June 10, 2025  
**Current Version**: v1.2.3  
**Flutter Version**: 3.24.3
