# Dotfiles

My configs for macOS and Linux. Still a work in progress.

# Ensure installed

- nvim
- tmux
- wezterm
- zsh
- aerospace
- starship
- fnm
- fzf
- lazygit
- uv
- go
- prettier
- prettierd

# Install

Install [Homebrew](https://brew.sh/) first.

```sh
git clone https://github.com/filiptodosovski/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh --packages
exec zsh -l
```

Creates symlinks and backs up existing configs in `~/.dotfiles-backup/`.

# Scripts

- `tmux-sessionizer` — pick a project. Ctrl-F, then `f` in tmux.
- `wt <branch> [base]` — create a worktree and open its tmux session.
- `dot doctor` — check the setup.
- `dot update` — update packages and plugins.

[Cheat sheet](nvim/CHEATSHEET.md)
