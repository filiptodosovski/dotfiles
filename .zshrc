# Resolve the symlink so the helpers also work from a different checkout path.
export DOTFILES_DIR="${${(%):-%x}:A:h}"
# Linux terminals often start a non-login shell, which skips .zprofile.
[[ -n "${HOMEBREW_PREFIX:-}" ]] || source "$DOTFILES_DIR/.zprofile"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship-core.toml}"
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
else
  export PNPM_HOME="${PNPM_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pnpm}"
fi
typeset -U path fpath
# Editor-only Mason executables should not override shell/Homebrew tools.
path=($HOME/.local/bin $PNPM_HOME ${path:#$HOME/.local/share/nvim/mason/bin})
export PATH

# Completion directories must be registered before compinit.
for directory in "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions" "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-completions" /usr/share/zsh/site-functions; do
  [[ -d "$directory" ]] && fpath=("$directory" $fpath)
done
unset directory
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ":completion:*" menu no

# Node versions, fuzzy search and Tab completion.
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"
for plugin in "${HOMEBREW_PREFIX:-/opt/homebrew}/share/fzf-tab/fzf-tab.zsh" "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh" /usr/share/fzf-tab/fzf-tab.plugin.zsh; do
  if [[ -r "$plugin" ]]; then source "$plugin"; break; fi
done
unset plugin
zstyle ":fzf-tab:*" fzf-flags --height=50% --layout=reverse --border
zstyle ":fzf-tab:*" switch-group "," "."
(( $+widgets[fzf-tab-complete] )) && bindkey "^I" fzf-tab-complete

# Shared history; a leading space keeps a command out of saved history.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_reduce_blanks hist_verify
setopt auto_cd interactive_comments
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Short aliases for everyday tools.
command -v eza >/dev/null && alias ls="eza --icons=always"
command -v bat >/dev/null && alias ccat="bat --style=plain --paging=never"
command -v fd >/dev/null && alias ff="fd"
command -v rg >/dev/null && alias rgf="rg --smart-case"
command -v rga >/dev/null && alias pdfgrep="rga"
command -v lazygit >/dev/null && alias lg="lazygit"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v starship >/dev/null && eval "$(starship init zsh)"

prompt-core() {
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship-core.toml"
  exec zsh -l
}
prompt-languages() {
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship-languages.toml"
  exec zsh -l
}
# Maintenance lives in the scripts, rather than in shell startup.
dot() {
  case "$1" in
    doctor) "$DOTFILES_DIR/scripts/bootstrap.sh" --check ;;
    update) "$DOTFILES_DIR/scripts/update.sh" "${@:2}" ;;
    prompt-core) prompt-core ;;
    prompt-languages) prompt-languages ;;
    *) echo "Usage: dot {doctor|update|prompt-core|prompt-languages}"; return 1 ;;
  esac
}
alias dot-doctor="dot doctor"
alias dot-update="dot update"

# Load highlighting last, after integrations have registered their widgets.
for plugin in "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [[ -r "$plugin" ]]; then source "$plugin"; break; fi
done
for plugin in "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$plugin" ]]; then source "$plugin"; break; fi
done
unset plugin
