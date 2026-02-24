# Dotfiles

Personal terminal/editor environment for macOS and Linux with:
- `zsh` + `starship`
- `tmux`
- `wezterm`
- `aerospace` (macOS)
- `neovim` (lazy.nvim)

## Structure

- `.zshrc`
- `tmux/.tmux.conf`
- `wezterm/wezterm.lua`
- `aerospace/aerospace.toml`
- `starship/starship-core.toml`
- `starship/starship-languages.toml`
- `nvim/` (full Neovim config)
- `scripts/dot-backup-keymaps.sh`

## Bootstrap

1. Clone repo:

```bash
git clone <your-repo-url> ~/.dotfiles
```

2. Create symlinks:

```bash
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
mkdir -p ~/.config/wezterm ~/.config/aerospace ~/.config/starship ~/.config/nvim
ln -sf ~/.dotfiles/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -sf ~/.dotfiles/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
ln -sf ~/.dotfiles/starship/starship-core.toml ~/.config/starship/starship-core.toml
ln -sf ~/.dotfiles/starship/starship-languages.toml ~/.config/starship/starship-languages.toml
ln -sf ~/.dotfiles/nvim ~/.config/nvim
```

3. Reload shell:

```bash
exec zsh -l
```

## Required tools

Core:
- `git`, `zsh`, `tmux`, `neovim`, `ripgrep`, `fd`, `bat`, `fzf`, `zoxide`, `starship`

Recommended:
- `atuin`, `eza`, `lazygit`
- LSP/format tools for TS: `vtsls`, `eslint_d`, `prettierd`, `prettier`

## Starship profiles

Default is the fast profile (`starship-core.toml`).

- Switch to core:

```bash
dot prompt-core
```

- Switch to language-heavy prompt:

```bash
dot prompt-languages
```

## Maintenance commands

- Update everything configured here:

```bash
dot update
```

- Run environment checks:

```bash
dot doctor
```

- Backup tmux + aerospace keymaps before experiments:

```bash
dot backup
```

## Backup workflow

- Script: `scripts/dot-backup-keymaps.sh`
- Output directory: `backups/`
- tmux hotkey: `<prefix> B`
- AeroSpace service mode key: `b`

## Neovim plugin stack highlights

Added for productivity and TS workflows:
- `which-key.nvim`
- `trouble.nvim`
- `conform.nvim`
- `nvim-lint`
- `mini.ai`
- `mini.surround`
- `toggleterm.nvim`

Formatting is now routed through `conform` in `<leader>f` and `:Format`, with LSP fallback.
