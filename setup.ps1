<#
setup.ps1
Mục tiêu:
 - Kiểm tra, cài đặt PuTTY & Wireshark nếu chưa có
 - Tạo thư mục C:\Program Files\EVE-NG
 - Copy file win11_64bit_putty.reg, win11_64bit_wireshark.reg, wireshark_wrapper.bat vào đó
 - Chạy 2 file .reg
#>

[CmdletBinding()]
param (
    [string]$WorkDir = "$env:TEMP\putty_wireshark_setup"
)

function Write-Log { param($m) $t=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); "$t  $m" | Tee-Object -FilePath (Join-Path $WorkDir "setup.log") -Append }

# --- require elevated ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script must be run as Administrator. Exiting." -ForegroundColor Red
    exit 1
}

New-Item -Path $WorkDir -ItemType Directory -Force | Out-Null
Write-Log "WorkDir: $WorkDir"

# --- candidate paths to detect existing installs ---
$puttyPaths = @(
    "$env:ProgramFiles\PuTTY\putty.exe",
    "$env:ProgramFiles(x86)\PuTTY\putty.exe"
)
$wiresharkPaths = @(
    "$env:ProgramFiles\Wireshark\Wireshark.exe",
    "$env:ProgramFiles(x86)\Wireshark\Wireshark.exe"
)

$puttyFound = $puttyPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
$wiresharkFound = $wiresharkPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($puttyFound) { Write-Log "PuTTY found: $puttyFound" } else { Write-Log "PuTTY not found" }
if ($wiresharkFound) { Write-Log "Wireshark found: $wiresharkFound" } else { Write-Log "Wireshark not found" }

# --- helper: download file ---
function Download-File {
    param($Url, $OutPath)
    Write-Log "Downloading $Url -> $OutPath"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing -ErrorAction Stop
        Write-Log "Downloaded $OutPath"
        return $true
    } catch {
        Write-Log "Download failed: $_"
        return $false
    }
}

# --- determine URLs ---
$puttyMsiUrl = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-installer.msi"
$wiresharkMsiUrl = "https://www.wireshark.org/download/win64/Wireshark-latest-x64.msi"

Write-Log "PuTTY URL: $puttyMsiUrl"
Write-Log "Wireshark URL: $wiresharkMsiUrl"

# --- install PuTTY ---
if (-not $puttyFound) {
    $puttyMsi = Join-Path $WorkDir "putty-installer.msi"
    if (Download-File -Url $puttyMsiUrl -OutPath $puttyMsi) {
        Write-Log "Installing PuTTY..."
        $args = "/i `"$puttyMsi`" /qn /norestart"
        Start-Process msiexec.exe -ArgumentList $args -Wait
    }
} else {
    Write-Log "PuTTY already installed."
}

# --- install Wireshark ---
if (-not $wiresharkFound) {
    $wiresharkMsi = Join-Path $WorkDir "wireshark-installer.msi"
    if (Download-File -Url $wiresharkMsiUrl -OutPath $wiresharkMsi) {
        Write-Log "Installing Wireshark..."
        $args = "/i `"$wiresharkMsi`" /qn /norestart"
        Start-Process msiexec.exe -ArgumentList $args -Wait
    }
} else {
    Write-Log "Wireshark already installed."
}

# --- Hàm tạo thư mục EVE-NG ---
function Create-EveNgFolder {
    $evePath = "C:\Program Files\EVE-NG"
    if (-not (Test-Path $evePath)) {
        New-Item -Path $evePath -ItemType Directory -Force | Out-Null
        Write-Log "Created folder: $evePath"
    } else {
        Write-Log "Folder already exists: $evePath"
    }
    return $evePath
}

# --- Hàm copy file vào EVE-NG ---
function Copy-FilesToEveNg {
    param($evePath)
    $files = @("win11_64bit_putty.reg", "win11_64bit_wireshark.reg", "wireshark_wrapper.bat")
    foreach ($f in $files) {
        $src = Join-Path $PSScriptRoot $f
        $dst = Join-Path $evePath $f
        if (Test-Path $src) {
            Copy-Item $src -Destination $dst -Force
            Write-Log "Copied $f -> $evePath"
        } else {
            Write-Log "File missing, cannot copy: $src"
        }
    }
}

# --- Hàm chạy 2 file reg ---
function Import-RegFiles {
    param($evePath)
    $regFiles = @(
        "win11_64bit_putty.reg",
        "win11_64bit_wireshark.reg"
    )
    foreach ($reg in $regFiles) {
        $regPath = Join-Path $evePath $reg
        if (Test-Path $regPath) {
            Write-Log "Importing registry file: $regPath"
            Start-Process reg.exe -ArgumentList "import `"$regPath`"" -Wait
        } else {
            Write-Log "Registry file not found: $regPath"
        }
    }
}

# --- Gọi 3 hàm ---
$evePath = Create-EveNgFolder
Copy-FilesToEveNg -evePath $evePath
Import-RegFiles -evePath $evePath

Write-Host ""
Write-Host "✅ Setup completed successfully!"
Write-Host "Files copied to: $evePath"
Write-Host "Registry entries imported."
Write-Host ""
Write-Log "Setup finished successfully."
