export DOTFILES_DIR="$HOME/.dotfiles"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/starship-core.toml}"
export PATH="$HOME/.local/bin:$PATH"

OS_NAME="$(uname -s)"

# 1. SETUP COMPLETIONS FPATH FIRST (Before compinit runs)
if [ "$OS_NAME" = "Darwin" ]; then
  [[ -d /opt/homebrew/share/zsh-completions ]] && fpath=(/opt/homebrew/share/zsh-completions $fpath)
elif [ "$OS_NAME" = "Linux" ]; then
  [[ -d /usr/share/zsh/site-functions ]] && fpath=(/usr/share/zsh/site-functions $fpath)
fi

# Initialize Completion Engine
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Allow bash-style completions
autoload -Uz bashcompinit && bashcompinit

# Register completions for common tools
command -v aws_completer >/dev/null 2>&1 && complete -C aws_completer aws
command -v terraform     >/dev/null 2>&1 && complete -o nospace -C "$(command -v terraform)" terraform
command -v gh            >/dev/null 2>&1 && eval "$(gh completion -s zsh 2>/dev/null)"

# Enable the menu picker fallback
zstyle ':completion:*' menu select
LISTMAX=0
zstyle ':completion:*' list-prompt   ''
zstyle ':completion:*' select-prompt ''

# 2. LOAD FZF-TAB (Must be after compinit, before zsh-syntax-highlighting)
for _fzf_tab_path in \
  "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh" \
  /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh \
  /usr/share/fzf-tab/fzf-tab.plugin.zsh; do
  if [[ -r "$_fzf_tab_path" ]]; then
    source "$_fzf_tab_path"
    break
  fi
done
unset _fzf_tab_path

(( $+functions[enable-fzf-tab] )) && enable-fzf-tab
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border --info=inline --cycle
zstyle ':fzf-tab:*' switch-group ',' '.'

# 3. CORE RUNTIMES & ENVIRONMENTS
# fnm is executed early here so Node environments are instantly ready
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"
setopt auto_cd interactive_comments

[[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# History Setup
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_reduce_blanks hist_verify

# 4. KEY BINDINGS (Declared before loading syntax-highlighting plugins)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

if (( $+widgets[fzf-tab-complete] )); then
  bindkey '^I' fzf-tab-complete
fi

# 5. HOOKS & PLUGINS (Disabling async overrides timing issues)
unset ZSH_AUTOSUGGEST_USE_ASYNC

if [ "$OS_NAME" = "Darwin" ]; then
  [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ "$OS_NAME" = "Linux" ]; then
  [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 6. EXTERNAL TOOLS & CLI ALIASES
command -v eza >/dev/null 2>&1 && alias ls="eza --icons=always"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v bat >/dev/null 2>&1 && alias ccat="bat --style=plain --paging=never"
command -v fd >/dev/null 2>&1 && alias ff="fd"
command -v rg >/dev/null 2>&1 && alias rgf="rg --smart-case"
command -v rga >/dev/null 2>&1 && alias pdfgrep="rga"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"

# Lazy-load legacy NVM if needed (kept fallback safe)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_load() {
    unset -f nvm node npm npx
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  }
  for _cmd in nvm node npm npx; do
    eval "${_cmd}() { _nvm_load; ${_cmd} \"\$@\"; }"
  done
  unset _cmd
fi

# 7. CUSTOM CORE UTILITIES & SHORTCUTS
prompt-core() {
  export STARSHIP_CONFIG="$HOME/.config/starship/starship-core.toml"
  exec zsh -l
}

prompt-languages() {
  export STARSHIP_CONFIG="$HOME/.config/starship/starship-languages.toml"
  exec zsh -l
}

_dot_doctor() {
  echo "OS: $(uname -s)"
  local tools=(
    nvim tmux wezterm starship git
    rg fd bat fzf zoxide eza lazygit atuin direnv fnm
    vtsls eslint_d prettierd prettier stylua shfmt taplo
    ruff black yarn
  )
  for cmd in "${tools[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf "%-12s OK (%s)\n" "$cmd" "$(command -v "$cmd")"
    else
      printf "%-12s MISSING\n" "$cmd"
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

dot() {
  case "$1" in
    update) _dot_update ;;
    doctor) _dot_doctor ;;
    prompt-core) prompt-core ;;
    prompt-languages) prompt-languages ;;
    *)
      echo "Usage: dot {update|doctor|prompt-core|prompt-languages}"
      return 1
      ;;
  esac
}

alias dot-update='dot update'
alias dot-doctor='dot doctor'
