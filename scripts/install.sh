#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Dotfiles Setup...${NC}"

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${BLUE}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -d "/opt/homebrew/bin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}Homebrew already installed.${NC}"
fi

# Install packages
PACKAGES=(
    "zsh" "eza" "zoxide" "fzf" "bat"
    "micro" "tmux" "yazi"
    "lazydocker"
)

echo -e "${BLUE}Installing packages...${NC}"
for package in "${PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo -e "${GREEN}$package already installed.${NC}"
    else
        echo -e "${BLUE}Installing $package...${NC}"
        brew install "$package"
    fi
done

# Install Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo -e "${BLUE}Cloning Zinit...${NC}"
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
    echo -e "${GREEN}Zinit already exists.${NC}"
fi

# Set Zsh as default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo -e "${BLUE}Changing default shell to zsh...${NC}"
    ZSH_PATH=$(which zsh)
    grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
else
    echo -e "${GREEN}Already using zsh.${NC}"
fi

echo -e "${GREEN}Installation complete! Restart your terminal or run 'zsh' now.${NC}"
