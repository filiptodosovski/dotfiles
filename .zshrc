export DOTFILES_DIR="$HOME/.dotfiles"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/starship-core.toml}"

OS_NAME="$(uname -s)"

# Better shell plugins (guarded for macOS/Linux)
if [ "$OS_NAME" = "Darwin" ]; then
  [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [[ -r /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh ]] && source /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh
  [[ -d /opt/homebrew/share/zsh-completions ]] && fpath=(/opt/homebrew/share/zsh-completions $fpath)
elif [ "$OS_NAME" = "Linux" ]; then
  [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [[ -r /usr/share/fzf-tab/fzf-tab.plugin.zsh ]] && source /usr/share/fzf-tab/fzf-tab.plugin.zsh
  [[ -d /usr/share/zsh/site-functions ]] && fpath=(/usr/share/zsh/site-functions $fpath)
fi

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
unset ZSH_AUTOSUGGEST_USE_ASYNC

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Better defaults
command -v eza >/dev/null 2>&1 && alias ls="eza --icons=always"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v bat >/dev/null 2>&1 && alias cat="bat --style=plain --paging=never"
command -v fd >/dev/null 2>&1 && alias ff="fd"
command -v rg >/dev/null 2>&1 && alias grep="rg"
command -v rga >/dev/null 2>&1 && alias pdfgrep="rga"

# atuin history (if installed)
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# Lazy-load nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  nvm() {
    unset -f nvm node npm npx
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }

  node() {
    unset -f nvm node npm npx
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    node "$@"
  }

  npm() {
    unset -f nvm node npm npx
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npm "$@"
  }

  npx() {
    unset -f nvm node npm npx
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npx "$@"
  }
fi

prompt-core() {
  export STARSHIP_CONFIG="$HOME/.config/starship/starship-core.toml"
  exec zsh -l
}

prompt-languages() {
  export STARSHIP_CONFIG="$HOME/.config/starship/starship-languages.toml"
  exec zsh -l
}

# dotfiles maintenance shortcuts
_dot_doctor() {
  echo "OS: $(uname -s)"
  for cmd in nvim tmux wezterm starship git rg fd bat zoxide; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf "%-10s OK (%s)\n" "$cmd" "$(command -v "$cmd")"
    else
      printf "%-10s MISSING\n" "$cmd"
    fi
  done
}

_dot_update() {
  if command -v brew >/dev/null 2>&1; then
    brew update && brew upgrade && brew cleanup
  fi

  if command -v nvim >/dev/null 2>&1; then
    XDG_CONFIG_HOME="$DOTFILES_DIR" nvim --headless '+Lazy! sync' +qa
  fi
}

_dot_backup() {
  "$DOTFILES_DIR/scripts/dot-backup-keymaps.sh"
}

# usage: dot update | dot doctor | dot backup | dot prompt-core | dot prompt-languages
dot() {
  case "$1" in
    update) _dot_update ;;
    doctor) _dot_doctor ;;
    backup) _dot_backup ;;
    prompt-core) prompt-core ;;
    prompt-languages) prompt-languages ;;
    *)
      echo "Usage: dot {update|doctor|backup|prompt-core|prompt-languages}"
      return 1
      ;;
  esac
}

alias dot-update='dot update'
alias dot-doctor='dot doctor'
alias dot-backup='dot backup'
