# --- Instant Prompt ---
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Environment ---
# Load custom env file if it exists
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Homebrew Setup
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Editor Config
export EDITOR=micro
export MICRO_TRUECOLOR=1
export PATH="$PATH:/home/deffa/.config/composer/vendor/bin"

# --- Zinit ---
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# --- Prompt & Essentials ---
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light fdellwing/zsh-bat

# --- Binaries (from GitHub Releases) ---
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

# --- OMZ Snippets ---
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx

# --- Syntax Highlighting (MUST be last plugin loaded) ---
zinit light zsh-users/zsh-syntax-highlighting

autoload -Uz compinit && compinit
zinit cdreplay -q

# --- History ---
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --- Completion ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# Use fzf to preview directories during cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# --- Key Bindings ---
bindkey -e # Emacs mode

# History Search (Up/Down arrow)
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
bindkey "$terminfo[kcud1]" history-beginning-search-forward-end

# Navigation
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Line Buffer Editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- Integrations ---
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# --- Aliases ---
# General
alias c='clear'
alias x='exit'
alias vim='nvim'
alias p='ping 8.8.8.8'
alias syu='sudo pacman -Syu'

# Eza (Better ls)
alias ls="eza --icons=auto --group-directories-first"
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

# Tools
alias lzd='lazydocker'
alias cw='warp-cli connect'
alias wd='warp-cli disconnect'
alias kubectl="minikube kubectl --"
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# --- Functions ---
# Yazi function (Shell wrapper to allow cd on exit)
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# --- Widgets ---
# Clear screen but keep current command buffer
function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle .reset-prompt
}
zle -N clear-screen-and-scrollback
bindkey '^Xl' clear-screen-and-scrollback

# --- Hotkey Insertions ---
# Insert git commit template (Ctrl+X, G, C)
# \C-b moves cursor back one position
bindkey -s '^Xgc' 'git commit -m ""\C-b'

# More examples:
bindkey -s '^Xgp' 'git push origin '
bindkey -s '^Xgs' 'git status\n'
bindkey -s '^Xgl' 'git log --oneline -n 10\n'
bindkey -s '^Xdu' 'docker compose up -d'
bindkey -s '^Xdb' 'docker compose up -d --build'
bindkey -s '^Xdd' 'docker compose down'

# --- Prompt ---
# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
