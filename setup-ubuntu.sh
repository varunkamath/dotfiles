#!/bin/bash

# Ubuntu Dotfiles Setup Script
# This script sets up a fresh Ubuntu machine with fish shell, starship prompt, and dotfiles

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

log_info "Starting Ubuntu dotfiles setup..."

# Update package lists
log_info "Updating package lists..."
sudo apt update

# Install required packages
log_info "Installing required packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Fish Shell
log_info "Installing Fish shell..."
sudo apt-add-repository ppa:fish-shell/release-3 -y
sudo apt update
sudo apt install -y fish

# Verify fish installation
if ! command -v fish &> /dev/null; then
    log_error "Fish installation failed"
    exit 1
fi
log_success "Fish shell installed successfully"

# Install Starship
log_info "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Verify starship installation
if ! command -v starship &> /dev/null; then
    log_error "Starship installation failed"
    exit 1
fi
log_success "Starship installed successfully"

# Create necessary directories
log_info "Creating configuration directories..."
mkdir -p ~/.config/fish
mkdir -p ~/.config/starship

# Get the current directory (should be the dotfiles repo)
DOTFILES_DIR="$(pwd)"

# Verify we're in the dotfiles repository
if [ ! -f "$DOTFILES_DIR/config.fish" ] || [ ! -f "$DOTFILES_DIR/starship.toml" ]; then
    log_error "This script must be run from inside the dotfiles repository"
    log_error "Expected files: config.fish, starship.toml"
    exit 1
fi

log_info "Using dotfiles from: $DOTFILES_DIR"

# Install configuration files
log_info "Installing configuration files..."

# Install fish config
cp "$DOTFILES_DIR/config.fish" ~/.config/fish/config.fish
log_success "Fish configuration installed"

# Install starship config
cp "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
log_success "Starship configuration installed"

# Install additional dependencies mentioned in config.fish
log_info "Installing additional dependencies..."

# Install zoxide (smart cd command)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install lsd (modern ls replacement)
if ! command -v lsd &> /dev/null; then
    log_info "Installing lsd..."
    LSD_VERSION=$(curl -s "https://api.github.com/repos/Peltoche/lsd/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
    wget "https://github.com/Peltoche/lsd/releases/download/${LSD_VERSION}/lsd_${LSD_VERSION}_amd64.deb" -O /tmp/lsd.deb
    sudo dpkg -i /tmp/lsd.deb || sudo apt-get install -f -y
    rm /tmp/lsd.deb
    log_success "lsd installed successfully"
fi

# Add fish to valid shells if not already present
if ! grep -q "$(which fish)" /etc/shells; then
    log_info "Adding fish to /etc/shells..."
    echo "$(which fish)" | sudo tee -a /etc/shells
fi

# Set fish as default shell
log_info "Setting fish as default shell..."
chsh -s "$(which fish)"

# Create fish completions directory
mkdir -p ~/.config/fish/completions

# Update fish completions
log_info "Updating fish completions..."
fish -c "fish_update_completions"

# Final setup message
log_success "Ubuntu dotfiles setup completed successfully!"
echo
log_info "Next steps:"
echo "  1. Log out and log back in (or restart) for the shell change to take effect"
echo "  2. Run 'fish_config' to customize fish shell settings"
echo
log_info "Configuration files installed:"
echo "  - Fish config: ~/.config/fish/config.fish"
echo "  - Starship config: ~/.config/starship.toml"
echo
log_warning "Note: Some features in your config.fish may require additional setup:"
echo "  - Homebrew paths are configured for macOS - you may need to adjust these"
echo "  - OrbStack integration is macOS-specific"
echo "  - Cargo/Rust environment setup will work if you install Rust later"
