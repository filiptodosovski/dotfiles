#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date +%Y%m%d-%H%M%S)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$DOTFILES_DIR/backups"

mkdir -p "$BACKUP_DIR/tmux" "$BACKUP_DIR/aerospace"

if [ -f "$HOME/.tmux.conf" ]; then
  cp "$HOME/.tmux.conf" "$BACKUP_DIR/tmux/tmux.conf.$STAMP"
fi

if [ -f "$HOME/.config/aerospace/aerospace.toml" ]; then
  cp "$HOME/.config/aerospace/aerospace.toml" "$BACKUP_DIR/aerospace/aerospace.toml.$STAMP"
fi

if [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]; then
  cp "$DOTFILES_DIR/tmux/.tmux.conf" "$BACKUP_DIR/tmux/repo.tmux.conf.$STAMP"
fi

if [ -f "$DOTFILES_DIR/aerospace/aerospace.toml" ]; then
  cp "$DOTFILES_DIR/aerospace/aerospace.toml" "$BACKUP_DIR/aerospace/repo.aerospace.toml.$STAMP"
fi

echo "Created keymap backups at $BACKUP_DIR"
