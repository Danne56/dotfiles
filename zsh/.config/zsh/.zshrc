# --- Instant Prompt ---
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Environment & PATH ---
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Load custom env file if present
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Homebrew Setup
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# PATH (typeset -U prevents duplicates)
typeset -U path
path=(
  ~/.local/bin
  ~/.opencode/bin
  ~/.symfony5/bin
  "${XDG_CONFIG_HOME:-$HOME/.config}/composer/vendor/bin"
  "${XDG_CONFIG_HOME:-$HOME/.config}/scripts"
  ~/.cache/.bun/bin
  $path
)

# --- Zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins & Prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light fdellwing/zsh-bat

# Binaries
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

# --- OMZ Snippets ---
# zinit snippet OMZL::git.zsh
# zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
zinit snippet OMZP::systemd
# zinit snippet OMZP::
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx

# Syntax Highlighting (must load after all other plugins)
zinit light zsh-users/zsh-syntax-highlighting

# Finalize completion system
autoload -Uz compinit && compinit
zinit cdreplay -q

# --- History ---
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_history"

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt interactive_comments

# --- Completion Styles ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33
zstyle ':completion:*' menu no
zstyle ':completion:*' squeeze-slashes false

# FZF previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# --- Key Bindings & Terminal ---
bindkey -e # Emacs mode

# Terminal tty reset
if [[ -t 0 ]]; then
  stty lnext undef
  bindkey -r '^V'
fi

typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Application mode handling for terminfo keys
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Arrow search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Navigation & Editing
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- Widgets ---
copy-current-line() {
  print -rn -- "$BUFFER" | wl-copy
}
zle -N copy-current-line
bindkey '^X^C' copy-current-line

function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle .reset-prompt
}
zle -N clear-screen-and-scrollback
bindkey '^l' clear-screen-and-scrollback

yazi_pick_path() {
  local file=$(yazi --chooser-file=>(cat))

  [[ -z "$file" ]] && zle redisplay && return

  LBUFFER+="\"$file\""
  zle redisplay
}

zle -N yazi_pick_path
bindkey '\ey' yazi_pick_path

# Hotkey string insertions
bindkey -s '^Xgc' 'git commit -m ""\C-b'
bindkey -s '^Xgp' 'git push origin '
bindkey -s '^Xgs' 'git status\n'
bindkey -s '^Xgl' 'git log --oneline -n 10\n'
bindkey -s '^Xdu' 'docker compose up -d'
bindkey -s '^Xdb' 'docker compose up -d --build'
bindkey -s '^Xdd' 'docker compose down'

# --- Integrations ---
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# --- Aliases & Functions ---
[[ -f "$HOME/.config/shell/alias" ]]    && source "$HOME/.config/shell/alias"
[[ -f "$HOME/.config/shell/function" ]] && source "$HOME/.config/shell/function"

# Global Aliases
alias -g NE='2>/dev/null'
alias -g NO='>/dev/null'
alias -g NUL='>/dev/null 2>&1'
alias -g J='| jq'
alias -g C='| wl-copy'

autoload -Uz zmv

# --- Hooks & Prompt ---
autoload -Uz add-zsh-hook

function auto_venv() {
  if [[ -n "$VIRTUAL_ENV" && "$PWD" != *"${VIRTUAL_ENV:h}"* ]]; then
    deactivate
    return
  fi

  [[ -n "$VIRTUAL_ENV" ]] && return

  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.venv/bin/activate" ]]; then
      source "$dir/.venv/bin/activate"
      return
    fi
    dir="${dir:h}"
  done
}
add-zsh-hook chpwd auto_venv

# Load Powerlevel10k theme configuration
[[ -f "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh" ]] && source "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh"
