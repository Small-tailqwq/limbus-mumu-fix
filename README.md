# Limbus Company MuMu 黑屏修复工具

修复 Limbus Company v1.106.x 在 MuMu 安卓模拟器上的黑屏问题。

**零外部依赖。** 直接从已安装的 APK 中提取两个 catalog 文件 —— 无需下载任何内容，不产生 payload 目录。

## 快速开始

### Windows

双击 `fix_mumu.bat`，或在 PowerShell 中运行：

```powershell
.\fix_mumu.ps1
```

### macOS / Linux

```bash
chmod +x fix_mumu.sh
./fix_mumu.sh
```

前提条件：`adb` 需在 PATH 中（macOS: `brew install android-platform-tools`）。

## 原理

```
split_UnityDataAssetPack.apk/assets/aa/catalog.bin
  → files/com.unity.addressables/catalog_S1.bin

split_UnityDataAssetPack.apk/assets/aa/catalog.hash
  → files/com.unity.addressables/catalog_S1.hash
```

两个文件。从 APK 自身提取。仅此而已。

## 为什么会出现黑屏

Limbus Company v1.106.x 升级到了 Unity 6。MuMu 的 Android 12 EGL/Vulkan 模拟层与 Unity 6 的图形初始化不兼容。Addressables 运行时 catalog 路径位于 split APK 内部，触发了黑屏。将相同的数据写入持久缓存，绕过有问题的路径即可解决。

## 选项

| 参数 | 说明 |
|------|------|
| `-s SERIAL` | 指定目标 ADB 设备（省略时自动检测） |
| `--no-launch` | 仅写入 catalog 文件，不启动游戏 |

## 恢复方法

```bash
adb shell "rm -rf /sdcard/Android/data/com.ProjectMoon.LimbusCompany/files/com.unity.addressables/*"
```

## 致谢

思路来源：小黑盒平台 [@Cangzhou](https://www.xiaoheihe.cn) 用户，其提供的修复包是开展本次 debug 分析的关键起点。

## 许可证

MIT
