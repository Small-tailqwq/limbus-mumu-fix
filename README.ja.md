# Limbus Company MuMu ブラックスクリーン修正ツール

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
