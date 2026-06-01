<#
.SYNOPSIS
    Fix Limbus Company v1.106.x black screen on MuMu emulator.
    Extracts catalog.bin/hash from the installed APK, no external files needed.
#>
param(
    [string]$Serial = "",
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"
$PackageName = "com.ProjectMoon.LimbusCompany"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir = "/sdcard/Android/data/$PackageName"
$CatalogDir = "$DataDir/files/com.unity.addressables"

$MuMuPorts = @(16384, 7555, 7556, 7557, 7558, 16416, 16448, 16480, 16512)

# --- Find ADB ---
function Get-AdbPath {
    $bundled = Join-Path $ScriptRoot "adb\adb.exe"
    if (Test-Path -LiteralPath $bundled) { return $bundled }
    $cmd = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command "adb" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

$AdbPath = Get-AdbPath
if (-not $AdbPath) {
    Write-Host "ERROR: adb not found." -ForegroundColor Red
    Write-Host "  - Install Android platform-tools"
    Write-Host "  - Or place adb.exe in the adb\ directory"
    exit 1
}
Write-Host "[*] Using adb: $AdbPath"

# --- Helper ---
function Invoke-Adb {
    $output = & $AdbPath @args 2>&1
    if ($LASTEXITCODE -ne 0) { throw "adb failed: $args`n$output" }
    return $output
}

function Invoke-AdbIgnore {
    & $AdbPath @args 2>&1 | Out-Null
}

# --- Start ADB, connect ---
Invoke-AdbIgnore start-server
foreach ($port in $MuMuPorts) {
    Invoke-AdbIgnore connect "127.0.0.1:$port"
}

# --- Find target device ---
if ($Serial) {
    Write-Host "[*] Using specified target: $Serial"
}
else {
    Write-Host "[*] Scanning for MuMu device with Limbus Company..."
    $devices = Invoke-Adb devices | Where-Object { $_ -match '^\S+\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] }
    foreach ($d in $devices) {
        $check = & $AdbPath -s $d shell "pm path $PackageName" 2>&1 | Out-String
        if ($check -match $PackageName) {
            $Serial = $d
            break
        }
    }
}

if (-not $Serial) {
    Write-Host "WARNING: Could not auto-detect MuMu device." -ForegroundColor Yellow
    $manualPort = Read-Host "  Enter MuMu ADB port manually (e.g. 16384), or press Enter to skip"
    if ($manualPort) {
        Invoke-AdbIgnore connect "127.0.0.1:$manualPort"
        $devices = Invoke-Adb devices | Where-Object { $_ -match '^\S+\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] }
        foreach ($d in $devices) {
            $check = & $AdbPath -s $d shell "pm path $PackageName" 2>&1 | Out-String
            if ($check -match $PackageName) {
                $Serial = $d
                break
            }
        }
    }
    if (-not $Serial) {
        Write-Host "ERROR: No MuMu device found. Make sure MuMu is running and the game is installed." -ForegroundColor Red
        exit 1
    }
}
Write-Host "[*] Target: $Serial"

# --- Get APK path ---
Write-Host "[*] Locating split_UnityDataAssetPack.apk..."
$apkRaw = & $AdbPath -s $Serial shell "pm path $PackageName" 2>&1 | Where-Object { $_ -match "UnityDataAssetPack" } | Select-Object -First 1
$apkPath = ($apkRaw -replace '^package:', '').Trim()
if (-not $apkPath) {
    Write-Host "ERROR: Could not find split_UnityDataAssetPack.apk" -ForegroundColor Red
    exit 1
}
Write-Host "[*] APK: $apkPath"

# --- Stop game ---
Write-Host "[*] Force stopping game..."
& $AdbPath -s $Serial shell "am force-stop $PackageName" 2>&1 | Out-Null
Start-Sleep -Seconds 1

# --- Create target dir ---
Write-Host "[*] Creating $CatalogDir ..."
& $AdbPath -s $Serial shell "mkdir -p $CatalogDir" 2>&1 | Out-Null

# --- Extract catalog files ---
$apkPathEscaped = $apkPath -replace "'", "'\''"
Write-Host "[*] Extracting catalog.bin -> catalog_S1.bin (4.5 MB)..."
& $AdbPath -s $Serial shell "unzip -p '$apkPathEscaped' assets/aa/catalog.bin > $CatalogDir/catalog_S1.bin" 2>&1 | Out-Null

Write-Host "[*] Extracting catalog.hash -> catalog_S1.hash (32 B)..."
& $AdbPath -s $Serial shell "unzip -p '$apkPathEscaped' assets/aa/catalog.hash > $CatalogDir/catalog_S1.hash" 2>&1 | Out-Null

# --- Verify ---
Write-Host "[*] Verifying target files:"
$verify = & $AdbPath -s $Serial shell "ls -la $CatalogDir/catalog_S1.bin $CatalogDir/catalog_S1.hash" 2>&1
Write-Host $verify

$binRaw = & $AdbPath -s $Serial shell "wc -c < $CatalogDir/catalog_S1.bin" 2>&1 | Out-String
$binSize = $binRaw.Trim()
if ([string]::IsNullOrEmpty($binSize) -or [int]$binSize -lt 100000) {
    Write-Host "ERROR: catalog_S1.bin appears invalid (size: $binSize)." -ForegroundColor Red
    exit 1
}
Write-Host "[*] catalog_S1.bin: $binSize bytes (expected ~4685282)"

$hashRaw = & $AdbPath -s $Serial shell "wc -c < $CatalogDir/catalog_S1.hash" 2>&1 | Out-String
$hashSize = $hashRaw.Trim()
if ($hashSize -ne "32") {
    Write-Host "ERROR: catalog_S1.hash should be 32 bytes, got: $hashSize." -ForegroundColor Red
    exit 1
}
Write-Host "[*] catalog_S1.hash: $hashSize bytes (expected 32)"

# --- Launch ---
if ($NoLaunch) {
    Write-Host "[*] -NoLaunch set. Catalog fix applied." -ForegroundColor Green
}
else {
    Write-Host "[*] Launching game..."
    & $AdbPath -s $Serial shell "monkey -p $PackageName -c android.intent.category.LAUNCHER 1" 2>&1 | Out-Null
    Write-Host ""
    Write-Host "Done. The game should reach the title screen." -ForegroundColor Green
}
