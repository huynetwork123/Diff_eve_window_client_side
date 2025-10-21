@echo off
REM setup.bat - run setup.ps1 elevated

SET SCRIPT_DIR=%~dp0
SET PS1=%SCRIPT_DIR%setup.ps1

REM Check if running elevated: try to create a folder in %windir%\system32 (common check) - fallback: use PowerShell to elevate
powershell -Command "if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%PS1%\"' -Verb RunAs; exit 0 } else { & 'powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '%PS1%'; exit 0 }"
exit /b %ERRORLEVEL%
