# Limbus Company MuMu 검은화면 수정 도구

[English](README.en.md) · [中文](README.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Limbus Company v1.106.x의 MuMu Android 에뮬레이터 검은화면 문제를 해결합니다.

**외부 의존성 제로.** 설치된 APK에서 두 개의 catalog 파일을 직접 추출합니다 — 다운로드 불필요, 페이로드 디렉토리 생성 없음.

## 빠른 시작

### Windows

`fix_mumu.bat`을 더블클릭하거나 PowerShell에서 실행:

```powershell
.\fix_mumu.ps1
```

### macOS / Linux

```bash
chmod +x fix_mumu.sh
./fix_mumu.sh
```

필수 조건: `adb`가 PATH에 있어야 함 (macOS: `brew install android-platform-tools`).

## 작동 원리

```
split_UnityDataAssetPack.apk/assets/aa/catalog.bin
  → files/com.unity.addressables/catalog_S1.bin

split_UnityDataAssetPack.apk/assets/aa/catalog.hash
  → files/com.unity.addressables/catalog_S1.hash
```

단 두 개의 파일. APK 자체에서 추출합니다. 이것이 전부입니다.

## 검은화면 발생 이유

Limbus Company v1.106.x는 Unity 6으로 업그레이드되었습니다. MuMu의 Android 12 EGL/Vulkan 에뮬레이션 레이어가 Unity 6의 그래픽 초기화와 호환되지 않습니다. split APK 내부의 Addressables 런타임 catalog 경로가 검은화면을 유발합니다. 동일한 데이터를 영구 캐시에 기록하여 문제가 있는 경로를 우회합니다.

## 공식 수정

시절을 잘못 만났습니다. 이 커뮤니티 수정이 완성되어 가는 바로 그때, Project Moon이 공식 수정을 발표했습니다：

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

이 커뮤니티 수정은 공식 업데이트가 도착할 때까지의 공백을 메웠습니다. 공식 업데이트가 이미 기기에 도착했다면 공식 버전 사용을 권장합니다.

## 옵션

| 옵션 | 설명 |
|------|------|
| `-s SERIAL` | 대상 ADB 장치 지정 (생략 시 자동 감지) |
| `--no-launch` | catalog 파일만 기록하고 게임을 실행하지 않음 |

## 복구 방법

```bash
adb shell "rm -rf /sdcard/Android/data/com.ProjectMoon.LimbusCompany/files/com.unity.addressables/*"
```

## 감사의 말

아이디어 출처: Xiaoheihe 플랫폼의 [Cangzhou](https://www.xiaoheihe.cn) 사용자. 제공해 주신 수정 패키지가 이 디버그 분석의 핵심적인 출발점이 되었습니다.

## 라이선스

MIT
