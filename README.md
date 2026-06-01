# Limbus Company MuMu 黑屏修复工具

[English](README.en.md) · [中文](README.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

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

## 官方修复

生不逢时。这个社区修复方案即将完成之际，Project Moon 也发布了官方修复公告：

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

社区修复在官方更新到来之前填补了空白。如果官方更新已推送至你的设备，建议直接使用官方版本。

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

思路来源：小黑盒平台 [Cangzhou](https://www.xiaoheihe.cn) 用户，其提供的修复包是开展本次 debug 分析的关键起点。

## 许可证

MIT
