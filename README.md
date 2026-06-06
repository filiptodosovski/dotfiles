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
- JS package manager: `yarn` (used by `:HealthTS`)

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

## Neovim plugin stack highlights

Added for productivity and TS workflows:
- `harpoon`
- `trouble.nvim`
- `conform.nvim`
- `nvim-lint`
- `mini.ai`
- `mini.surround`
- `mini.pairs`
- `mini.comment` (+ `nvim-ts-context-commentstring` for JSX/TSX)
- `nvim-navic` (LSP breadcrumbs in lualine)
- `vim-test`
- `lazygit.nvim`

Formatting is routed through `conform` in `<leader>f` and `:Format`, with LSP fallback.

Useful keys:
- Neovim LazyGit: `<leader>gg` (also `<leader>lg`)
- LazyGit current file: `<leader>gc`
- Test nearest/file/last: `<leader>tn` / `<leader>tf` / `<leader>tl`
- TS health check: `<leader>ch`
