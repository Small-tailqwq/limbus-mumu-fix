@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0fix_mumu.ps1" %*
set "ERR=%ERRORLEVEL%"

if "%ERR%"=="0" (
  echo.
  echo [OK] Hotfix finished.
) else (
  echo.
  echo [FAILED] Hotfix failed with exit code %ERR%.
)
pause
exit /b %ERR%
