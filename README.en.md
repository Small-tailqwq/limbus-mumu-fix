# Limbus Company MuMu Black Screen Fix

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
