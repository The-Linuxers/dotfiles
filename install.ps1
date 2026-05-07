#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles install script (Windows)
.DESCRIPTION
    Checks dependencies, installs missing software, and symlinks configs.
    Run from an elevated (Admin) PowerShell if symbolic links fail.
#>
[CmdletBinding()]
param(
    [switch]$Test
)

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinNeovimVersion = [version]"0.12.0"

$ConfigRoot = if ($Test) {
    $testRoot = Join-Path $DotfilesDir "test" "AppData" "Local"
    $null = New-Item -ItemType Directory -Path $testRoot -Force
    Write-Info "TEST MODE: using $testRoot as config directory"
    $testRoot
} else {
    $env:LOCALAPPDATA
}

function Write-Info  { param([string]$Message) Write-Host "[INFO]  $Message" -ForegroundColor Green }
function Write-Warn  { param([string]$Message) Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
function Write-ErrorMsg { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------

function Get-NeovimVersion {
    try {
        $output = & nvim --version 2>$null | Select-Object -First 1
        if ($output -match 'v?(\d+\.\d+\.\d+)') {
            return [version]$Matches[1]
        } elseif ($output -match 'v?(\d+\.\d+)') {
            return [version]("$($Matches[1]).0")
        }
    } catch {
        return $null
    }
    return $null
}

function Test-Neovim {
    $ver = Get-NeovimVersion
    if (-not $ver) {
        return $false
    }
    if ($ver -ge $MinNeovimVersion) {
        Write-Info "Neovim $ver is installed (>= $MinNeovimVersion)"
        return $true
    } else {
        Write-Warn "Neovim $ver is installed, but >= $MinNeovimVersion is required"
        return $false
    }
}

function Install-Neovim {
    if (Test-Neovim) { return }

    Write-Info "Attempting to install Neovim..."

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing Neovim via winget..."
        winget install Neovim.Neovim --accept-package-agreements --accept-source-agreements
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Installing Neovim via Chocolatey..."
        choco install neovim -y
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Info "Installing Neovim via Scoop..."
        scoop install neovim
    } else {
        Write-ErrorMsg "No supported package manager found (winget, choco, scoop)."
        Write-ErrorMsg "Please install Neovim >= $MinNeovimVersion manually from:"
        Write-ErrorMsg "  https://github.com/neovim/neovim/releases"
        exit 1
    }

    # Refresh PATH in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (-not (Test-Neovim)) {
        Write-Warn "Neovim was installed but version check still fails."
        Write-Warn "Please restart your terminal and re-run this script."
    }
}

# ------------------------------------------------------------------------------
# Symlinking
# ------------------------------------------------------------------------------

function Backup-AndLink {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Destination) {
        $item = Get-Item $Destination
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Write-Info "Removing existing symlink: $Destination"
            Remove-Item $Destination -Force
        } else {
            $backup = "$Destination.backup.$(Get-Date -Format yyyyMMddHHmmss)"
            Write-Warn "Backing up existing config: $Destination -> $backup"
            Rename-Item $Destination $backup
        }
    }

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        Write-Info "Linked: $Destination -> $Source"
    } catch [System.UnauthorizedAccessException] {
        Write-ErrorMsg "Permission denied creating symlink: $Destination"
        Write-ErrorMsg "Enable Windows Developer Mode, or run this script as Administrator."
        throw
    }
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

function Main {
    Write-Info "Dotfiles directory: $DotfilesDir"

    Write-Info "=== Checking / Installing Neovim ==="
    if ($Test) {
        if (Test-Neovim) {
            Write-Info "Neovim check passed"
        } else {
            Write-Warn "Neovim not found or outdated"
        }
    } else {
        Install-Neovim
    }

    Write-Info "=== Linking configurations ==="
    $nvimDest = Join-Path $ConfigRoot "nvim"
    Backup-AndLink -Source (Join-Path $DotfilesDir "nvim") -Destination $nvimDest

    if ($Test) {
        Write-Info "TEST MODE: configs linked under $ConfigRoot"
    }
    Write-Info "Done. You may need to restart your terminal."
}

Main
