# Cross-platform PowerShell script to install GCC 14 from source
param(
    [string]$InstallPath = $(if ($IsWindows) { "C:\gcc-14" } else { "$HOME/gcc-14" }),
    [string]$BuildPath = $(if ($IsWindows) { "C:\temp\gcc-build" } else { "/tmp/gcc-build" })
)

$ErrorActionPreference = "Stop"

Write-Host "Installing GCC 14 from source..." -ForegroundColor Green

# Check for required privileges
if ($IsWindows) {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as Administrator on Windows"
        exit 1
    }
} else {
    # Check if we can write to the install path or if we need sudo
    if (-not (Test-Path (Split-Path $InstallPath -Parent) -PathType Container)) {
        Write-Host "May need sudo privileges for installation..." -ForegroundColor Yellow
    }
}

# Install dependencies based on OS
Write-Host "Installing dependencies..." -ForegroundColor Yellow
if ($IsWindows) {
    # Windows - assume MSYS2 or similar environment
    Write-Host "Ensure you have MSYS2 with build tools installed" -ForegroundColor Yellow
} elseif ($IsMacOS) {
    # macOS
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        brew install gmp mpfr libmpc
    } else {
        Write-Error "Homebrew not found. Please install Homebrew first."
        exit 1
    }
} else {
    # Linux - detect package manager
    if (Get-Command apt-get -ErrorAction SilentlyContinue) {
        sudo apt-get update
        sudo apt-get install -y build-essential libgmp-dev libmpfr-dev libmpc-dev
    } elseif (Get-Command yum -ErrorAction SilentlyContinue) {
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y gmp-devel mpfr-devel libmpc-devel
    } elseif (Get-Command pacman -ErrorAction SilentlyContinue) {
        sudo pacman -S --noconfirm base-devel gmp mpfr libmpc
    } else {
        Write-Error "Unsupported Linux distribution. Please install build tools manually."
        exit 1
    }
}

# Create directories
New-Item -ItemType Directory -Path $BuildPath -Force | Out-Null
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

# Download GCC 14 source
$gccUrl = "https://gcc.gnu.org/releases/gcc-14.2.0/gcc-14.2.0.tar.xz"
$gccArchive = "$BuildPath/gcc-14.2.0.tar.xz"

Write-Host "Downloading GCC 14.2.0 source..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $gccUrl -OutFile $gccArchive

# Extract archive
Write-Host "Extracting source archive..." -ForegroundColor Yellow
Set-Location $BuildPath
tar -xf $gccArchive

# Download prerequisites
Set-Location "$BuildPath/gcc-14.2.0"
Write-Host "Downloading prerequisites..." -ForegroundColor Yellow
if ($IsWindows) {
    & ".\contrib\download_prerequisites"
} else {
    & "./contrib/download_prerequisites"
}

# Create build directory
$buildDir = "$BuildPath/gcc-build"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
Set-Location $buildDir

# Configure build
Write-Host "Configuring build..." -ForegroundColor Yellow
$configArgs = @(
    "--prefix=$InstallPath",
    "--enable-languages=c,c++",
    "--disable-multilib"
)

if (-not $IsWindows) {
    $configArgs += "--enable-threads=posix"
}

$configScript = if ($IsWindows) { "$BuildPath\gcc-14.2.0\configure" } else { "$BuildPath/gcc-14.2.0/configure" }
& $configScript @configArgs

# Determine number of cores
$numCores = if ($IsWindows) {
    (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
} else {
    nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || 4
}

# Build GCC
Write-Host "Building GCC (this may take several hours)..." -ForegroundColor Yellow
make "-j$numCores"

# Install GCC
Write-Host "Installing GCC..." -ForegroundColor Yellow
if ($IsWindows -or (Test-Path $InstallPath -PathType Container)) {
    make install
} else {
    sudo make install
}

# Add to PATH
Write-Host "Adding GCC to PATH..." -ForegroundColor Yellow
if ($IsWindows) {
    $env:PATH = "$InstallPath\bin;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH, "Machine")
} else {
    # Add to current session
    $env:PATH = "$InstallPath/bin:$env:PATH"
    
    # Add to shell profile
    $shellProfile = if ($IsMacOS) { "$HOME/.zshrc" } else { "$HOME/.bashrc" }
    $pathExport = "export PATH=`"$InstallPath/bin:`$PATH`""
    
    if (Test-Path $shellProfile) {
        if (-not (Select-String -Path $shellProfile -Pattern [regex]::Escape($pathExport) -Quiet)) {
            Add-Content -Path $shellProfile -Value $pathExport
        }
    } else {
        Set-Content -Path $shellProfile -Value $pathExport
    }
}

Write-Host "GCC 14 installation completed!" -ForegroundColor Green
Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan
Write-Host "Please restart your shell or run 'source ~/.bashrc' (Linux) / 'source ~/.zshrc' (macOS) to use the new GCC installation." -ForegroundColor Yellow