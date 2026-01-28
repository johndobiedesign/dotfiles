#!/bin/bash

# Dotfiles Installation Script
# Installs ghostty, nushell, starship, micro, node, pnpm, and JetBrainsMono Nerd Font
# Supports macOS and Linux

set -e  # Exit on error

# Parse command line arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]] || [[ "$1" == "-d" ]]; then
    DRY_RUN=true
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR"

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo -e "${RED}[✗]${NC} Unsupported OS: $OSTYPE"
    exit 1
fi

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dotfiles Installation Script  ${NC}"
echo -e "${BLUE}================================${NC}\n"

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY RUN MODE - No changes will be made]${NC}\n"
fi

echo -e "${BLUE}Dotfiles directory: ${NC}$DOTFILES_DIR"
echo -e "${BLUE}Operating system:   ${NC}$OS\n"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[→]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_dry_run() {
    echo -e "${CYAN}[DRY RUN]${NC} Would execute: $1"
}

# Check if Homebrew is installed
print_info "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Install Homebrew"
        print_dry_run "Add Homebrew to PATH"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH permanently
        if [[ "$OS" == "macos" ]] && [[ $(uname -m) == "arm64" ]]; then
            # Apple Silicon Mac
            if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile 2>/dev/null; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            fi
        elif [[ "$OS" == "linux" ]]; then
            # Linux
            if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.profile 2>/dev/null; then
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
            fi
            # Also add to ~/.bashrc for interactive non-login shells
            if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.bashrc 2>/dev/null; then
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            fi
        fi
        print_status "Homebrew installed"
    fi
else
    print_status "Homebrew already installed"
fi

# Ensure Homebrew is in PATH for this script session
if [ "$DRY_RUN" = false ]; then
    if [[ "$OS" == "macos" ]] && [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ "$OS" == "macos" ]] && [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [[ "$OS" == "linux" ]] && [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Update Homebrew
print_info "Updating Homebrew..."
if [ "$DRY_RUN" = true ]; then
    print_dry_run "brew update"
else
    brew update
    print_status "Homebrew updated"
fi

# Install applications
echo -e "\n${BLUE}Installing applications...${NC}\n"

# Install Ghostty
print_info "Installing Ghostty..."
if command -v ghostty &> /dev/null; then
    print_warning "Ghostty already installed, skipping"
elif [[ "$OS" == "macos" ]]; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install --cask ghostty"
    else
        brew install --cask ghostty
        print_status "Ghostty installed"
    fi
else
    # Linux - try brew install (non-cask), fall back to manual instructions
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install ghostty"
    else
        if brew install ghostty 2>/dev/null; then
            print_status "Ghostty installed"
        else
            print_warning "Ghostty not available via Homebrew on this system"
            print_info "Install manually: https://ghostty.org/docs/install/binary"
        fi
    fi
fi

# Install Nushell
print_info "Installing Nushell..."
if command -v nu &> /dev/null; then
    print_warning "Nushell already installed, skipping"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install nushell"
    else
        brew install nushell
        print_status "Nushell installed"
    fi
fi

# Install Starship
print_info "Installing Starship..."
if command -v starship &> /dev/null; then
    print_warning "Starship already installed, skipping"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install starship"
    else
        brew install starship
        print_status "Starship installed"
    fi
fi

# Install Micro
print_info "Installing Micro..."
if command -v micro &> /dev/null; then
    print_warning "Micro already installed, skipping"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install micro"
    else
        brew install micro
        print_status "Micro installed"
    fi
fi

# Install Node.js
print_info "Installing Node.js..."
if command -v node &> /dev/null; then
    print_warning "Node.js already installed ($(node --version)), skipping"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install node"
    else
        brew install node
        print_status "Node.js installed"
    fi
fi

# Install pnpm
print_info "Installing pnpm..."
if command -v pnpm &> /dev/null; then
    print_warning "pnpm already installed ($(pnpm --version)), skipping"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install pnpm"
    else
        brew install pnpm
        print_status "pnpm installed"
    fi
fi

# Install JetBrainsMono Nerd Font
print_info "Installing JetBrainsMono Nerd Font..."
if [[ "$OS" == "macos" ]]; then
    if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
        print_warning "JetBrainsMono Nerd Font already installed, skipping"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "brew install --cask font-jetbrains-mono-nerd-font"
        else
            brew install --cask font-jetbrains-mono-nerd-font
            print_status "JetBrainsMono Nerd Font installed"
        fi
    fi
else
    # Linux - install font to ~/.local/share/fonts
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [ -d "$FONT_DIR" ]; then
        print_warning "JetBrainsMono Nerd Font already installed, skipping"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Download and install JetBrainsMono Nerd Font to $FONT_DIR"
        else
            print_info "Downloading JetBrainsMono Nerd Font..."
            mkdir -p "$FONT_DIR"
            curl -fsSL -o /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
            rm /tmp/JetBrainsMono.zip
            fc-cache -fv > /dev/null 2>&1 || true
            print_status "JetBrainsMono Nerd Font installed"
        fi
    fi
fi

# Create config directories
echo -e "\n${BLUE}Setting up configuration directories...${NC}\n"

CONFIG_DIR="$HOME/.config"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "mkdir -p $CONFIG_DIR/ghostty"
    print_dry_run "mkdir -p $CONFIG_DIR/nushell"
    print_dry_run "mkdir -p $CONFIG_DIR/micro"
else
    mkdir -p "$CONFIG_DIR/ghostty"
    mkdir -p "$CONFIG_DIR/nushell"
    mkdir -p "$CONFIG_DIR/micro"
    print_status "Config directories created"
fi

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [ ! -f "$source" ] && [ ! -d "$source" ]; then
        print_error "Source file not found: $source"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        # In dry-run mode, just show what would happen
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            print_dry_run "mv $target $backup"
        elif [ -L "$target" ]; then
            print_dry_run "rm $target"
        fi
        print_dry_run "ln -s $source $target"
    else
        # If target exists and is not a symlink, back it up
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "$name config exists, backing up to: $backup"
            mv "$target" "$backup"
        elif [ -L "$target" ]; then
            print_info "Removing existing $name symlink"
            rm "$target"
        fi
        
        # Create the symlink
        ln -s "$source" "$target"
        print_status "$name config symlinked: $target -> $source"
    fi
}

# Setup Ghostty configuration
echo -e "\n${BLUE}Linking Ghostty configuration...${NC}"
create_symlink "$DOTFILES_DIR/ghostty/config" "$CONFIG_DIR/ghostty/config" "Ghostty config"
create_symlink "$DOTFILES_DIR/ghostty/cursor_sweep.glsl" "$CONFIG_DIR/ghostty/cursor_sweep.glsl" "Ghostty shader"

# Setup Nushell configuration
echo -e "\n${BLUE}Linking Nushell configuration...${NC}"
create_symlink "$DOTFILES_DIR/nushell/config.nu" "$CONFIG_DIR/nushell/config.nu" "Nushell config"
create_symlink "$DOTFILES_DIR/nushell/env.nu" "$CONFIG_DIR/nushell/env.nu" "Nushell env"

# Setup Starship configuration
echo -e "\n${BLUE}Linking Starship configuration...${NC}"
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml" "Starship"

# Setup Micro configuration
echo -e "\n${BLUE}Linking Micro configuration...${NC}"
create_symlink "$DOTFILES_DIR/micro/settings.json" "$CONFIG_DIR/micro/settings.json" "Micro"

# Add Nushell to valid shells if not already present
echo -e "\n${BLUE}Configuring Nushell as a valid shell...${NC}"
SHELL_CHANGED=false
if command -v nu &> /dev/null; then
    NU_PATH=$(command -v nu)
    if ! grep -q "$NU_PATH" /etc/shells 2>/dev/null; then
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "echo $NU_PATH | sudo tee -a /etc/shells"
        else
            print_info "Adding Nushell to /etc/shells (requires sudo)"
            echo "$NU_PATH" | sudo tee -a /etc/shells > /dev/null
            print_status "Nushell added to /etc/shells"
        fi
    else
        print_warning "Nushell already in /etc/shells"
    fi
    
    # Prompt to set Nushell as default shell
    if [ "$DRY_RUN" = false ]; then
        CURRENT_SHELL=$(basename "$SHELL")
        if [[ "$CURRENT_SHELL" != "nu" ]]; then
            echo ""
            read -p "$(echo -e ${YELLOW}Would you like to set Nushell as your default shell? [y/N] ${NC})" -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Changing default shell to Nushell..."
                chsh -s "$NU_PATH"
                print_status "Default shell changed to Nushell"
                SHELL_CHANGED=true
            else
                print_info "Keeping current shell ($CURRENT_SHELL)"
            fi
        else
            print_status "Nushell is already your default shell"
            SHELL_CHANGED=true
        fi
    else
        print_dry_run "Prompt: Would you like to set Nushell as your default shell?"
    fi
else
    print_warning "Nushell not found, skipping shell configuration"
fi

# Final summary
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}  Installation Complete! ✓      ${NC}"
echo -e "${GREEN}================================${NC}\n"

echo -e "${BLUE}Installed applications:${NC}"
echo -e "  • Ghostty  (Terminal emulator)"
echo -e "  • Nushell  (Modern shell)"
echo -e "  • Starship (Shell prompt)"
echo -e "  • Micro    (Text editor)"
echo -e "  • Node.js  (JavaScript runtime)"
echo -e "  • pnpm     (Fast package manager)"
echo -e "  • JetBrainsMono Nerd Font\n"

echo -e "${BLUE}Configuration files linked:${NC}"
echo -e "  • ~/.config/ghostty/config"
echo -e "  • ~/.config/ghostty/cursor_sweep.glsl"
echo -e "  • ~/.config/nushell/config.nu"
echo -e "  • ~/.config/nushell/env.nu"
echo -e "  • ~/.config/starship.toml"
echo -e "  • ~/.config/micro/settings.json\n"

echo -e "${YELLOW}Next steps:${NC}"
STEP=1
echo -e "  $STEP. Start a new terminal session (to load Homebrew PATH)"
((STEP++))
if [ "$SHELL_CHANGED" = false ]; then
    echo -e "  $STEP. To switch your default shell to Nushell, run:"
    echo -e "     ${GREEN}chsh -s \$(command -v nu)${NC}"
    ((STEP++))
fi
echo -e "  $STEP. Launch Nushell:"
echo -e "     ${GREEN}nu${NC}"
((STEP++))
echo -e "  $STEP. Launch Ghostty to use your terminal emulator"
((STEP++))
echo -e "  $STEP. Micro is configured as your default text editor with simple colorscheme"
echo -e "\n${BLUE}Note:${NC} Your configurations are symlinked, so any changes you make"
echo -e "will automatically be reflected in your dotfiles directory.\n"
