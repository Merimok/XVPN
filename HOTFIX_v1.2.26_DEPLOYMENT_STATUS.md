# Hotfix v1.2.26 Deployment Status

## Summary
This hotfix addresses persistent GitHub Actions build failures for the Flutter Windows application. The primary changes involve:
- Corrected `cmake_minimum_required()` and `project()` command placement in `windows/CMakeLists.txt`.
- Ensured `FLUTTER_TARGET_PLATFORM` is set before `add_subdirectory(flutter)` in `windows/CMakeLists.txt`.
- Removed the custom `INSTALL` target in `windows/CMakeLists.txt` to rely on standard CMake install project generation, aiming to resolve the `INSTALL.vcxproj` not found error.

## Changes Made
- **vpn_client/windows/CMakeLists.txt:**
    - Moved `cmake_minimum_required(VERSION 3.15)` and `project(vpn_client LANGUAGES CXX)` to the absolute top of the file.
    - Ensured `set(FLUTTER_TARGET_PLATFORM "windows-x64")` is defined before `add_subdirectory(flutter)`.
    - Removed the `add_custom_target(INSTALL ALL ...)` block.
- **vpn_client/pubspec.yaml:** Incremented version to `1.2.26+26`.

## Verification Steps
- [ ] Monitor GitHub Actions build for this commit.
- [ ] Confirm CMake warnings related to `project()` and `cmake_minimum_required()` are resolved.
- [ ] Confirm MSBUILD error `INSTALL.vcxproj cannot be found` is resolved.
- [ ] Confirm successful build and artifact generation for Windows.

## Rollback Plan
- Revert the changes in `vpn_client/windows/CMakeLists.txt` to the v1.2.25 state.
- Revert `pubspec.yaml` to `1.2.25+25`.
- Re-introduce the custom `INSTALL` target if necessary, or investigate alternative solutions for the `INSTALL.vcxproj` issue.
