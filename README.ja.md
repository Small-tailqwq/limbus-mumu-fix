# Limbus Company MuMu ブラックスクリーン修正ツール

[English](README.en.md) · [中文](README.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Limbus Company v1.106.x の MuMu Android エミュレータにおけるブラックスクリーン問題を修正します。

**外部依存ゼロ。** インストール済みの APK から 2 つの catalog ファイルを直接抽出します — ダウンロード不要、ペイロードディレクトリも生成しません。

## クイックスタート

### Windows

`fix_mumu.bat` をダブルクリックするか、PowerShell で実行：

```powershell
.\fix_mumu.ps1
```

### macOS / Linux

```bash
chmod +x fix_mumu.sh
./fix_mumu.sh
```

前提条件：`adb` が PATH に含まれていること（macOS: `brew install android-platform-tools`）。

## 仕組み

```
split_UnityDataAssetPack.apk/assets/aa/catalog.bin
  → files/com.unity.addressables/catalog_S1.bin

split_UnityDataAssetPack.apk/assets/aa/catalog.hash
  → files/com.unity.addressables/catalog_S1.hash
```

たった 2 つのファイル。APK 自身から抽出するだけです。

## ブラックスクリーンの原因

Limbus Company v1.106.x は Unity 6 にアップグレードされました。MuMu の Android 12 EGL/Vulkan エミュレーションレイヤーが Unity 6 のグラフィックス初期化と互換性がありません。split APK 内部の Addressables ランタイム catalog パスがブラックスクリーンを引き起こします。同じデータを永続キャッシュに書き込むことで、問題のあるパスを回避します。

## 公式修正

生まれる時を得ず。このコミュニティ修正が完成しつつあるちょうどその時、Project Moon から公式修正が発表されました：

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

このコミュニティ修正は、公式アップデートが届くまでの間を埋めるものです。公式アップデートがすでに配信されている場合は、公式版の使用をお勧めします。

## オプション

| オプション | 説明 |
|-----------|------|
| `-s SERIAL` | 対象 ADB デバイスを指定（省略時は自動検出） |
| `--no-launch` | catalog ファイルの書き込みのみ行い、ゲームを起動しない |

## 復元方法

```bash
adb shell "rm -rf /sdcard/Android/data/com.ProjectMoon.LimbusCompany/files/com.unity.addressables/*"
```

## 謝辞

アイデアの出典：小黑盒プラットフォームの [Cangzhou](https://www.xiaoheihe.cn) ユーザー。提供いただいた修正パッケージが、本デバッグ解析の鍵となりました。

## ライセンス

MIT
