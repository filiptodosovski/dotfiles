#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR
PLATFORM="$(uname -s)"

if [[ "${1:-}" == --dry-run && $# -eq 1 ]]; then
  cat <<'PLAN'
Update Homebrew metadata and packages listed in Brewfile.
Refresh WezTerm nightly with --greedy-latest on macOS (Linux terminals are managed separately).
Install the latest Node LTS and make it the fnm default.
Back up lazy-lock.json, then update Neovim plugins, parsers and configured servers.
Update installed tmux plugins; leave plugins pinned to tags unchanged.
PLAN
  exit 0
fi
if [[ $# -gt 0 ]]; then
  echo 'Usage: update.sh [--dry-run]' >&2
  exit 2
fi
[[ "$PLATFORM" == Darwin || "$PLATFORM" == Linux ]] || { echo 'This updater supports macOS and Linux.' >&2; exit 1; }
for brew_binary in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [[ -x "$brew_binary" ]]; then
    eval "$("$brew_binary" shellenv)"
    break
  fi
done
command -v brew >/dev/null 2>&1 || { echo 'Homebrew is missing: https://brew.sh' >&2; exit 1; }

brew update
brew bundle install --file "$DOTFILES_DIR/Brewfile"
if [[ "$PLATFORM" == Darwin ]]; then
  brew upgrade --cask wezterm@nightly --greedy-latest
fi
eval "$(fnm env --shell bash)"
fnm install --lts --use
fnm default "$(fnm current)"

mkdir -p "$HOME/.dotfiles-backup"
backup="$(mktemp -d "$HOME/.dotfiles-backup/update-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
cp "$DOTFILES_DIR/nvim/lazy-lock.json" "$backup/lazy-lock.json"
export DOTFILES_BOOTSTRAP=1
nvim --headless '+Lazy! update' +qa
nvim --headless -c 'lua dofile(vim.env.DOTFILES_DIR .. "/scripts/nvim-tools.lua")' -c qall

while read -r plugin; do
  if [[ "$plugin" == *'#'* ]]; then
    printf 'keeping tmux pin  %s\n' "$plugin"
    continue
  fi
  name="${plugin##*/}"
  directory="$HOME/.tmux/plugins/$name"
  if [[ -d "$directory/.git" ]]; then
    git -C "$directory" pull --ff-only
  else
    printf 'missing tmux plugin  %s; run bootstrap.sh to install it\n' "$name" >&2
    exit 1
  fi
done < <(awk '/^set -g @plugin/ { gsub(/[\047\042]/, "", $4); print $4 }' "$DOTFILES_DIR/tmux/.tmux.conf")

echo "Previous Neovim lockfile: $backup/lazy-lock.json"
echo 'Updates complete. Restart Neovim and start a new terminal.'
