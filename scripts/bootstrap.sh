#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR
BACKUP_DIR=""
INSTALL_PACKAGES=false
DRY_RUN=false
CHECK_ONLY=false
LINKS_ONLY=false
PLATFORM="$(uname -s)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

usage() {
  cat <<'USAGE'
Usage: bootstrap.sh [--packages] [--links-only] [--dry-run] [--check]

  --packages    Install/upgrade the Brewfile and current Node LTS.
  --links-only  Create symlinks without downloading packages or plugins.
  --dry-run     Print the plan without changing anything.
  --check       Check links, tools, versions, plugins, parsers and servers.

Existing configs are backed up before replacement. Homebrew must be installed
first for --packages; see https://brew.sh. Without --packages, tools must already
be installed. macOS and Linux are supported; install your Linux terminal separately.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --packages) INSTALL_PACKAGES=true ;;
    --links-only) LINKS_ONLY=true ;;
    --dry-run) DRY_RUN=true ;;
    --check) CHECK_ONLY=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done
if { $CHECK_ONLY && { $DRY_RUN || $INSTALL_PACKAGES || $LINKS_ONLY; }; } || { $LINKS_ONLY && $INSTALL_PACKAGES; }; then
  echo "--check must be used alone; --links-only cannot be combined with --packages." >&2
  exit 2
fi

# Find Homebrew on both Apple Silicon and Intel, even in a fresh shell.
for brew_binary in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [[ -x "$brew_binary" ]]; then
    eval "$("$brew_binary" shellenv)"
    break
  fi
done

link_specs=(
  "$DOTFILES_DIR/.zprofile|$HOME/.zprofile"
  "$DOTFILES_DIR/.zshrc|$HOME/.zshrc"
  "$DOTFILES_DIR/tmux/.tmux.conf|$HOME/.tmux.conf"
  "$DOTFILES_DIR/wezterm|$CONFIG_DIR/wezterm"
  "$DOTFILES_DIR/starship|$CONFIG_DIR/starship"
  "$DOTFILES_DIR/nvim|$CONFIG_DIR/nvim"
  "$DOTFILES_DIR/bin/tmux-sessionizer|$HOME/.local/bin/tmux-sessionizer"
  "$DOTFILES_DIR/bin/wt|$HOME/.local/bin/wt"
)
if [[ "$PLATFORM" == Darwin ]]; then
  link_specs+=("$DOTFILES_DIR/aerospace|$CONFIG_DIR/aerospace")
elif [[ "$PLATFORM" != Linux ]]; then
  echo 'This setup supports macOS and Linux.' >&2
  exit 1
fi

same_file() { [[ -e "$2" && "$1" -ef "$2" ]]; }

link_dotfile() {
  local source="$1" target="$2" relative_target
  if same_file "$source" "$target"; then
    printf 'already linked  %s\n' "$target"
    return
  fi
  if $DRY_RUN; then
    [[ ! -e "$target" && ! -L "$target" ]] || printf 'would back up  %s\n' "$target"
    printf 'would link     %s -> %s\n' "$target" "$source"
    return
  fi
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      mkdir -p "$HOME/.dotfiles-backup"
      BACKUP_DIR="$(mktemp -d "$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-XXXXXX")"
    fi
    relative_target="${target#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$relative_target")"
    mv "$target" "$BACKUP_DIR/$relative_target"
    printf 'backed up      %s\n' "$target"
  fi
  ln -s "$source" "$target"
  printf 'linked         %s\n' "$target"
}

has_monolisa() {
  local fonts="$HOME/Library/Fonts"
  [[ "$PLATFORM" != Linux ]] || fonts="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  [[ -d "$fonts" ]] || return 1
  find "$fonts" -type f \
    \( -iname 'MonoLisa-Regular.ttf' -o -iname 'MonoLisa-Regular.otf' \) \
    -print -quit 2>/dev/null | grep -q .
}

install_linux_font() {
  local fonts="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/Meslo" download
  if [[ -f "$fonts/MesloLGSNerdFontMono-Regular.ttf" ]]; then return; fi
  download="$(mktemp -d)"
  curl -fL --retry 2 https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -o "$download/Meslo.zip"
  mkdir -p "$fonts"
  unzip -jo "$download/Meslo.zip" 'MesloLGSNerdFontMono-Regular.ttf' -d "$fonts"
  fc-cache -f "$fonts"
  rm -rf "$download"
}

# Compare numeric versions without sort -V (not available on stock macOS).
version_at_least() {
  local actual="$1" required="$2" a b c x y z
  IFS=. read -r a b c <<< "$actual"
  IFS=. read -r x y z <<< "$required"
  (( a > x || (a == x && b > y) || (a == x && b == y && ${c:-0} >= ${z:-0}) ))
}

check_tools() {
  local failed=0 command output actual
  local commands=(git zsh nvim tmux starship fnm node pnpm go prettier prettierd uv ruff ty stylua tree-sitter fzf atuin bat eza fd rg lazygit zoxide jq cc curl tar)
  if [[ "$PLATFORM" == Darwin ]]; then commands+=(wezterm aerospace); fi
  for command in "${commands[@]}"; do
    if command -v "$command" >/dev/null 2>&1; then
      printf '%-18s %s\n' 'tool OK' "$command"
    else
      printf '%-18s %s\n' 'tool MISSING' "$command"
      failed=1
    fi
  done
  for command in nvim tree-sitter; do
    command -v "$command" >/dev/null 2>&1 || continue
    output="$("$command" --version)"
    if [[ "$output" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
      actual="${BASH_REMATCH[1]}"
      local minimum=0.12.0
      [[ "$command" != tree-sitter ]] || minimum=0.26.1
      if version_at_least "$actual" "$minimum"; then
        printf '%-18s %s %s\n' 'version OK' "$command" "$actual"
      else
        printf '%-18s %s needs >= %s (found %s)\n' 'version TOO OLD' "$command" "$minimum" "$actual"
        failed=1
      fi
    else
      printf 'Cannot read %s version\n' "$command" >&2
      failed=1
    fi
  done
  return "$failed"
}

check_setup() {
  local failed=0 spec source target plugin name
  for spec in "${link_specs[@]}"; do
    IFS='|' read -r source target <<< "$spec"
    if same_file "$source" "$target"; then
      printf '%-18s %s\n' 'link OK' "$target"
    else
      printf '%-18s %s\n' 'link MISSING' "$target"
      failed=1
    fi
  done
  check_tools || failed=1
  while read -r plugin; do
    plugin="${plugin%%#*}"
    name="${plugin##*/}"
    if [[ -d "$HOME/.tmux/plugins/$name/.git" ]]; then
      printf '%-18s %s\n' 'tmux plugin OK' "$name"
    else
      printf '%-18s %s\n' 'tmux plugin MISSING' "$name"
      failed=1
    fi
  done < <(awk '/^set -g @plugin/ { gsub(/[\047\042]/, "", $4); print $4 }' "$DOTFILES_DIR/tmux/.tmux.conf")
  if command -v nvim >/dev/null 2>&1; then
    DOTFILES_CHECK=1 NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n \
      -c 'lua dofile(vim.env.DOTFILES_DIR .. "/scripts/nvim-tools.lua")' -c qall || failed=1
  fi
  if has_monolisa; then
    echo 'font OK            MonoLisa Regular'
  else
    echo 'font OPTIONAL      MonoLisa is not installed; Meslo fallback is used.'
  fi
  if [[ "$PLATFORM" == Linux ]]; then
    command -v wezterm >/dev/null 2>&1 || echo 'terminal OPTIONAL  Install WezTerm separately, or use your existing terminal.'
    echo 'shell NOTE         Start Zsh with: zsh -l (changing the login shell is up to you).'
  fi
  return "$failed"
}

if $CHECK_ONLY; then
  check_setup
  exit $?
fi
if $INSTALL_PACKAGES; then
  if $DRY_RUN; then
    echo 'would install  Brewfile packages and the current Node LTS'
    [[ "$PLATFORM" != Linux ]] || echo 'would install  Meslo Nerd Font in the user fonts directory'
  else
    command -v brew >/dev/null 2>&1 || { echo 'Install Homebrew first: https://brew.sh' >&2; exit 1; }
    if [[ "$PLATFORM" == Darwin ]]; then
      brew tap nikitabobko/tap
      brew trust --cask nikitabobko/tap/aerospace
    fi
    brew bundle install --file "$DOTFILES_DIR/Brewfile"
    [[ "$PLATFORM" != Linux ]] || install_linux_font
    eval "$(fnm env --shell bash)"
    fnm install --lts --use
    fnm default "$(fnm current)"
  fi
fi
if ! $DRY_RUN && ! $LINKS_ONLY; then
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --shell bash)"
  fi
  check_tools || { echo 'Install missing tools before continuing (or use --packages).' >&2; exit 1; }
fi
for spec in "${link_specs[@]}"; do
  IFS='|' read -r source target <<< "$spec"
  link_dotfile "$source" "$target"
done
if $DRY_RUN; then
  if ! $LINKS_ONLY; then
    echo 'would install  TPM and configured tmux plugins'
    echo 'would restore  locked Neovim plugins and install parsers/servers'
  fi
  exit 0
fi
if ! $LINKS_ONLY; then
  mkdir -p "$HOME/.tmux/plugins"
  if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  export DOTFILES_BOOTSTRAP=1
  nvim --headless '+Lazy! restore' +qa
  nvim --headless -c 'lua dofile(vim.env.DOTFILES_DIR .. "/scripts/nvim-tools.lua")' -c qall
fi
[[ -z "$BACKUP_DIR" ]] || echo "Previous configs are saved in: $BACKUP_DIR"
echo 'Setup complete. Start a new terminal, or run: exec zsh -l'
