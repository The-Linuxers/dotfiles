#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIN_NEOVIM_VERSION="0.12"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
dbg()   { echo -e "${BLUE}[DBG]${NC}   $*"; }

# compare versions: true if $1 >= $2
version_ge() {
    local a="$1" b="$2"
    # Pad to three numeric components and compare
    local a_pad b_pad
    a_pad=$(echo "$a" | awk -F. '{printf "%04d%04d%04d", $1, $2, $3}')
    b_pad=$(echo "$b" | awk -F. '{printf "%04d%04d%04d", $1, $2, $3}')
    [ "$a_pad" -ge "$b_pad" ]
}

# extract versions
extract_version() {
    local raw="$1"
    echo "$raw" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1
}

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------

check_neovim() {
    if ! command -v nvim &>/dev/null; then
        return 1
    fi

    local installed
    installed=$(extract_version "$(nvim --version | head -n1)")

    if [ -z "$installed" ]; then
        return 1
    fi

    if version_ge "$installed" "$MIN_NEOVIM_VERSION"; then
        info "Neovim $installed is installed (>= $MIN_NEOVIM_VERSION)"
        return 0
    else
        warn "Neovim $installed is installed, but >= $MIN_NEOVIM_VERSION is required"
        return 1
    fi
}

install_neovim_macos() {
    if command -v brew &>/dev/null; then
        info "Installing Neovim via Homebrew"
        brew install neovim
    else
        error "Homebrew not found. Neovim not installed"
    fi
}

install_neovim_linux() {
    info "install Neovim via system package manager..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y neovim
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm neovim
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y neovim
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y neovim
    elif command -v apk &>/dev/null; then
        sudo apk add neovim
    else
        error "Unknown package manager. Please install Neovim $MIN_NEOVIM_VERSION manually."
        return 1
    fi
}

install_neovim() {
    if check_neovim; then
			info "nvim already installed"
        return 0
    fi

    local os
    os=$(uname -s)
    case "$os" in
        Darwin)
            install_neovim_macos
            ;;
        Linux)
            install_neovim_linux
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            error "Windows detected. Please use the install.ps1 PowerShell script instead."
            return 1
            ;;
        *)
            error "Unsupported OS: $os"
            return 1
            ;;
    esac

    if ! check_neovim; then
        warn "Package manager may have installed an older Neovim version."
        warn "Please install Neovim >= $MIN_NEOVIM_VERSION manually:"
        warn "  https://github.com/neovim/neovim/releases"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Ghostty
# ------------------------------------------------------------------------------

check_ghostty() {
    command -v ghostty &>/dev/null
}

install_ghostty_macos() {
    if command -v brew &>/dev/null; then
        info "Installing Ghostty via Homebrew..."
        brew install --cask ghostty
    else
        warn "Homebrew not found. Skipping Ghostty install."
        warn "Download it from: https://ghostty.org/download"
    fi
}

# install commands from: https://ghostty.org/docs/install/binary#linux
install_ghostty_linux() {
    info "Attempting to install Ghostty..."

    if command -v pacman &>/dev/null; then
        info "Installing Ghostty from Arch Linux extra repository..."
        sudo pacman -S --needed --noconfirm ghostty

    elif command -v apk &>/dev/null; then
        info "Installing Ghostty from Alpine testing repository..."
        sudo apk add ghostty

    elif command -v emerge &>/dev/null; then
        info "Installing Ghostty from Gentoo repository..."
        sudo emerge -av ghostty

    elif command -v xbps-install &>/dev/null; then
        info "Installing Ghostty from Void Linux repository..."
        sudo xbps-install -Sy ghostty

    elif command -v eopkg &>/dev/null; then
        info "Installing Ghostty from Solus repository..."
        sudo eopkg install ghostty

    elif command -v snap &>/dev/null; then
        info "Installing Ghostty via Snap..."
        sudo snap install ghostty --classic

    elif command -v dnf &>/dev/null; then
        info "Installing Ghostty on Fedora via COPR..."

        if ! command -v copr &>/dev/null; then
            sudo dnf install -y dnf-plugins-core
        fi

        sudo dnf copr enable -y scottames/ghostty
        sudo dnf install -y ghostty

    elif command -v rpm-ostree &>/dev/null; then
        info "Installing Ghostty on Fedora Atomic/Silverblue..."

        . /etc/os-release

        curl -fsSL \
            "https://copr.fedorainfracloud.org/coprs/scottames/ghostty/repo/fedora-${VERSION_ID}/scottames-ghostty-fedora-${VERSION_ID}.repo" \
            | sudo tee /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo >/dev/null

        sudo rpm-ostree refresh-md
        sudo rpm-ostree install ghostty

        warn "Reboot required to use Ghostty."

    elif command -v apt-get &>/dev/null; then
        info "Installing Ghostty on Ubuntu/Debian..."

        if grep -qiE "ubuntu" /etc/os-release; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
        else
            warn "Official Debian repositories do not provide Ghostty."
            warn "Options:"
            warn "  - Community packages: https://github.com/mkasberg/ghostty-ubuntu"
            warn "  - Build from source: https://ghostty.org/docs/install/build"
            warn "  - AppImage: https://github.com/pkgforge-dev/ghostty-appimage"
        fi

    elif command -v nix-env &>/dev/null; then
        info "Installing Ghostty via Nix..."
        nix-env -iA nixpkgs.ghostty

    elif command -v flatpak &>/dev/null; then
        warn "No native package source detected."
        warn "Using Flatpak as fallback..."
        flatpak install -y flathub com.mitchellh.ghostty

    else
        warn "No supported package manager found for Ghostty."
        warn "See installation docs:"
        warn "  https://ghostty.org/docs/install/binary"
    fi
}

install_ghostty() {
    if check_ghostty; then
        info "Ghostty is already installed."
        return 0
    fi

    local os
    os=$(uname -s)
    case "$os" in
        Darwin)
            install_ghostty_macos
            ;;
        Linux)
            install_ghostty_linux
            ;;
        *)
            warn "Ghostty is not supported on this OS. Skipping."
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Symlinking
# ------------------------------------------------------------------------------
backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        if [ -t 0 ]; then
            read -r -p "Symlink exists at $dest. Remove it? [y/N] " choice
            case "$choice" in
                y|Y)
                    info "Removing existing symlink: $dest"
                    rm "$dest"
                    ;;
                *)
                    warn "Skipping symlink removal: $dest"
                    return 0
                    ;;
            esac
        else
            warn "Symlink exists and no TTY available: skipping $dest"
            return 1
        fi

    elif [ -e "$dest" ]; then
        local backup="${dest}.backup.$(date +%s)"
        warn "Backing up existing config: $dest -> $backup"
        mv "$dest" "$backup"
    fi

    if ln -s "$src" "$dest"; then
        info "Linked: $dest -> $src"
    else
        warn "Failed to link: $dest -> $src"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    local config_dir
    if [ -n "${1:-}" ]; then
        config_dir="$1"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
        config_dir="$XDG_CONFIG_HOME"
    else
        config_dir="$HOME/.config"
    fi

    info "Dotfiles directory: $DOTFILES_DIR"
    info "Config directory: $config_dir"

    info "=== Checking / Installing Neovim ==="
    install_neovim

    info "=== Checking / Installing Ghostty ==="
    install_ghostty

    info "=== Linking configurations ==="
    mkdir -p "$config_dir"

    backup_and_link "$DOTFILES_DIR/nvim" "$config_dir/nvim"
    backup_and_link "$DOTFILES_DIR/ghostty" "$config_dir/ghostty"
}

main "$@"
