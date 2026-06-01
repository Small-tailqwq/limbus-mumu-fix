# Limbus Company MuMu Black Screen Fix

[English](README.en.md) · [中文](README.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Fix for the Limbus Company v1.106.x black screen on MuMu Android emulator.

**Zero external dependencies.** Extracts two catalog files from the installed APK — nothing to download, no payload directory.

## Quick Start

### Windows

Double-click `fix_mumu.bat`, or run from PowerShell:

```powershell
.\fix_mumu.ps1
```

### macOS / Linux

```bash
chmod +x fix_mumu.sh
./fix_mumu.sh
```

Requirement: `adb` in PATH (`brew install android-platform-tools` on macOS).

## How It Works

```
split_UnityDataAssetPack.apk/assets/aa/catalog.bin
  → files/com.unity.addressables/catalog_S1.bin

split_UnityDataAssetPack.apk/assets/aa/catalog.hash
  → files/com.unity.addressables/catalog_S1.hash
```

Two files. From the APK itself. That's it.

## Why the Black Screen Occurs

Limbus Company v1.106.x upgraded to Unity 6. MuMu's Android 12 EGL/Vulkan emulation layer is incompatible with Unity 6's graphics initialization. The Addressables runtime catalog path inside the split APK triggers the black screen. Seeding the same bytes as persistent cache bypasses the problematic path.

## Official Fix

Born at the wrong time. Just as this community fix was being finalized, Project Moon released an official fix announcement:

> Hello, this is Project Moon.
>
> We would like to inform you that, regarding the previously announced inaccessibility issue on AOS, we have identified the cause of the error and developed a fix.
>
> We are currently preparing the game build with the completed fix. The update will be deployed once the store review process is complete.
>
> [ Issue Cause ]
> - There was an issue in which the order of certain code logic was not clearly executed during the resource-loading process required to run the Limbus Company application.
> - As a result, on certain devices, the application was unable to complete loading and entered indefinite loading.
>
> [ Fix Details ]
> - We have isolated the cause of the issue through close cooperation between our internal team and Unity's technical support team.
> - We have supplemented the design logic so that resources can now be loaded properly. We have also confirmed that the issue no longer persists on our internal testing devices.
>
> [ Fix Schedule ]
> - We will prepare a new application build with the fix as quickly as possible. The submission process is underway for market review.
> - Once the market review has been completed, we will distribute the update without delay so that Managers using AOS can play the game normally.
>
> ※ We will inform you via a separate notice once the market review is complete and clearance for the game update is obtained.
>
> Once again, we sincerely apologize for the inconvenience.

This community fix filled the gap until the official update arrives. If the official update has already reached your device, using the official version is recommended.

## Options

| Option | Description |
|--------|-------------|
| `-s SERIAL` | Target specific ADB device (auto-detect if omitted) |
| `--no-launch` | Only seed catalog files, don't launch the game |

## Recovery

```bash
adb shell "rm -rf /sdcard/Android/data/com.ProjectMoon.LimbusCompany/files/com.unity.addressables/*"
```

## Credits

Inspired by [Cangzhou](https://www.xiaoheihe.cn) on Xiaoheihe platform. The fix package provided by this user was the key that unlocked the debug analysis.

## License

MIT
