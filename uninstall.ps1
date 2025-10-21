# ================================
# EVE-NG Client Uninstaller Script
# Author: You
# ================================

Write-Host "=== GỠ CÀI ĐẶT EVE-NG CLIENT PACK ===" -ForegroundColor Cyan

# Kiểm tra quyền admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Vui lòng chạy script này bằng quyền Administrator!"
    exit 1
}

# 1️⃣ Xóa registry PuTTY và Wireshark
Write-Host ">> Xóa registry key liên quan đến PuTTY và Wireshark..."

$regPaths = @(
    "HKCU:\SOFTWARE\Classes\Putty.telnet",
    "HKCU:\SOFTWARE\Putty",
    "HKCU:\SOFTWARE\RegisteredApplications",
    "HKCU:\SOFTWARE\Classes\telnet\shell",
    "HKCU:\SOFTWARE\Classes\capture"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force
            Write-Host "  Đã xóa $path"
        } catch {
            Write-Warning "  Không thể xóa $path — $_"
        }
    }
}

# 2️⃣ Xóa thư mục EVE-NG
$installDir = "C:\Program Files\EVE-NG"
if (Test-Path $installDir) {
    Write-Host ">> Xóa thư mục $installDir..."
    Remove-Item -Path $installDir -Recurse -Force
    Write-Host "  Đã xóa thư mục EVE-NG"
}

# 3️⃣ Tùy chọn: gỡ cài đặt Wireshark và PuTTY (nếu setup.ps1 cài qua winget)
Write-Host ">> Gỡ cài đặt Wireshark và PuTTY (nếu có)..."
$apps = @("Wireshark", "PuTTY")
foreach ($app in $apps) {
    $pkg = winget list --name $app | Select-String $app
    if ($pkg) {
        Write-Host "  Gỡ $app..."
        winget uninstall --name $app --silent
    } else {
        Write-Host "  $app chưa được cài hoặc cài thủ công."
    }
}

Write-Host "`n=== HOÀN TẤT GỠ CÀI ĐẶT ===" -ForegroundColor Green
