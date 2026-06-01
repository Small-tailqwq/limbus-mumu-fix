#!/bin/bash
set -e

PACKAGE="com.ProjectMoon.LimbusCompany"
DATA_DIR="/sdcard/Android/data/${PACKAGE}"
CATALOG_DIR="${DATA_DIR}/files/com.unity.addressables"
TARGET_SERIAL=""
NO_LAUNCH=false

MUMU_PORTS=(16384 7555 7556 7557 7558 16416 16448 16480 16512)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Fix Limbus Company v1.106.x black screen on MuMu emulator.
Extracts catalog.bin and catalog.hash from the installed APK and
seeds them as persistent Addressables catalog cache.

Options:
  -s, --serial SERIAL    Target specific ADB device (auto-detect if omitted)
  --no-launch            Only seed the catalog files, don't launch the game
  -h, --help             Show this help

Requirements:
  - adb in PATH, or bundled at adb/adb (macOS/Linux) or adb/adb.exe (Windows)
  - MuMu emulator running with Limbus Company v1.106.x installed
EOF
    exit 0
}

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--serial)
            TARGET_SERIAL="$2"; shift 2 ;;
        --no-launch)
            NO_LAUNCH=true; shift ;;
        -h|--help)
            usage ;;
        *)
            echo "Unknown option: $1"
            usage ;;
    esac
done

# --- Find ADB ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

find_adb() {
    local bundled="$SCRIPT_DIR/adb/adb"
    if [[ -f "$bundled" ]]; then
        echo "$bundled"
        return
    fi
    local bundled_exe="$SCRIPT_DIR/adb/adb.exe"
    if [[ -f "$bundled_exe" ]]; then
        echo "$bundled_exe"
        return
    fi
    if command -v adb &>/dev/null; then
        echo "adb"
        return
    fi
    echo ""
}

ADB=$(find_adb)
if [[ -z "$ADB" ]]; then
    echo -e "${RED}ERROR: adb not found.${NC}"
    echo "  - Install Android platform-tools (brew install android-platform-tools on macOS)"
    echo "  - Or place adb binary in the adb/ directory"
    exit 1
fi
echo "[*] Using adb: $ADB"

# --- Start ADB and connect to known MuMu ports ---
$ADB start-server

for port in "${MUMU_PORTS[@]}"; do
    $ADB connect "127.0.0.1:${port}" 2>/dev/null || true
done

# --- Auto-detect target device ---
if [[ -n "$TARGET_SERIAL" ]]; then
    echo "[*] Using specified target: $TARGET_SERIAL"
else
    echo "[*] Scanning for MuMu device with Limbus Company..."
    while IFS=$'\t' read -r serial _; do
        serial="${serial//[[:space:]]/}"
        if [[ -z "$serial" ]]; then continue; fi
        if $ADB -s "$serial" shell "pm path $PACKAGE" 2>/dev/null | grep -q "$PACKAGE"; then
            TARGET_SERIAL="$serial"
            break
        fi
    done < <($ADB devices | grep -w 'device$')
fi

if [[ -z "$TARGET_SERIAL" ]]; then
    echo -e "\033[0;33mWARNING: Could not auto-detect MuMu device.\033[0m"
    read -p "  Enter MuMu ADB port manually (e.g. 16384), or press Enter to skip: " MANUAL_PORT
    if [[ -n "$MANUAL_PORT" ]]; then
        $ADB connect "127.0.0.1:${MANUAL_PORT}" 2>/dev/null || true
        while IFS=$'\t' read -r serial _; do
            serial="${serial//[[:space:]]/}"
            if [[ -z "$serial" ]]; then continue; fi
            if $ADB -s "$serial" shell "pm path $PACKAGE" 2>/dev/null | grep -q "$PACKAGE"; then
                TARGET_SERIAL="$serial"
                break
            fi
        done < <($ADB devices | grep -w 'device$')
    fi
    if [[ -z "$TARGET_SERIAL" ]]; then
        echo -e "${RED}ERROR: No MuMu device found. Make sure MuMu is running and the game is installed.${NC}"
        exit 1
    fi
fi
echo "[*] Target: $TARGET_SERIAL"

# --- Locate the split APK ---
echo "[*] Locating split_UnityDataAssetPack.apk..."
APK=$($ADB -s "$TARGET_SERIAL" shell "pm path $PACKAGE" | grep "UnityDataAssetPack" | head -1 | cut -d: -f2- | tr -d '\r\n ')

if [[ -z "$APK" ]]; then
    echo -e "${RED}ERROR: Could not find split_UnityDataAssetPack.apk${NC}"
    exit 1
fi
echo "[*] APK: $APK"

# --- Stop game ---
echo "[*] Force stopping game..."
$ADB -s "$TARGET_SERIAL" shell "am force-stop $PACKAGE" 2>/dev/null || true
sleep 1

# --- Create target directory ---
echo "[*] Creating $CATALOG_DIR ..."
$ADB -s "$TARGET_SERIAL" shell "mkdir -p $CATALOG_DIR"

# --- Extract catalog files from APK directly on device ---
echo "[*] Extracting catalog.bin -> catalog_S1.bin (4.5 MB)..."
$ADB -s "$TARGET_SERIAL" shell "unzip -p '$APK' assets/aa/catalog.bin > $CATALOG_DIR/catalog_S1.bin" 2>&1

echo "[*] Extracting catalog.hash -> catalog_S1.hash (32 B)..."
$ADB -s "$TARGET_SERIAL" shell "unzip -p '$APK' assets/aa/catalog.hash > $CATALOG_DIR/catalog_S1.hash" 2>&1

# --- Verify sizes ---
echo "[*] Verifying target files:"
$ADB -s "$TARGET_SERIAL" shell "ls -la $CATALOG_DIR/catalog_S1.bin $CATALOG_DIR/catalog_S1.hash"

BIN_SIZE=$($ADB -s "$TARGET_SERIAL" shell "wc -c < $CATALOG_DIR/catalog_S1.bin" | tr -d '[:space:]')
if [[ -z "$BIN_SIZE" || "$BIN_SIZE" -lt 100000 ]]; then
    echo -e "${RED}ERROR: catalog_S1.bin appears invalid (size: ${BIN_SIZE:-unknown}).${NC}"
    exit 1
fi
echo "[*] catalog_S1.bin: ${BIN_SIZE} bytes (expected ~4685282)"

HASH_SIZE=$($ADB -s "$TARGET_SERIAL" shell "wc -c < $CATALOG_DIR/catalog_S1.hash" | tr -d '[:space:]')
if [[ "$HASH_SIZE" != "32" ]]; then
    echo -e "${RED}ERROR: catalog_S1.hash should be 32 bytes, got: ${HASH_SIZE:-unknown}.${NC}"
    exit 1
fi
echo "[*] catalog_S1.hash: ${HASH_SIZE} bytes (expected 32)"

# --- Launch ---
if $NO_LAUNCH; then
    echo -e "${GREEN}[*] --no-launch set. Catalog fix applied.${NC}"
else
    echo "[*] Launching game..."
    $ADB -s "$TARGET_SERIAL" shell "monkey -p $PACKAGE -c android.intent.category.LAUNCHER 1" 2>&1
    echo ""
    echo -e "${GREEN}Done. The game should reach the title screen.${NC}"
fi
