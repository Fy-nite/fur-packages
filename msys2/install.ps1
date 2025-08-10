# MSYS2 Installation Script
param(
    [string]$InstallPath = "C:\msys64",
    [switch]$AddToPath
)

$ErrorActionPreference = "Stop"

# Download URL for MSYS2
$msys2Url = "https://github.com/msys2/msys2-installer/releases/latest/download/msys2-x86_64-latest.exe"
$installerPath = "$env:TEMP\msys2-installer.exe"

Write-Host "Downloading MSYS2 installer..." -ForegroundColor Green
Invoke-WebRequest -Uri $msys2Url -OutFile $installerPath

Write-Host "Installing MSYS2 to $InstallPath..." -ForegroundColor Green
Start-Process -FilePath $installerPath -ArgumentList "--confirm-command", "--accept-messages", "--root", $InstallPath -Wait

# Initialize MSYS2
Write-Host "Initializing MSYS2..." -ForegroundColor Green
& "$InstallPath\usr\bin\bash.exe" -lc "pacman --noconfirm -Syuu"
& "$InstallPath\usr\bin\bash.exe" -lc "pacman --noconfirm -Su"

# Add to PATH if requested
if ($AddToPath) {
    Write-Host "Adding MSYS2 to PATH..." -ForegroundColor Green
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$InstallPath\usr\bin*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallPath\usr\bin", "User")
    }
}

# Cleanup
Remove-Item $installerPath -Force

Write-Host "MSYS2 installation completed!" -ForegroundColor Green