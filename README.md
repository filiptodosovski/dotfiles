# Dotfiles

My configs for macOS and Linux. Still a work in progress.

## Ensure installed

- nvim
- tmux
- wezterm
- zsh
- aerospace
- starship
- fnm
- uv
- go
- prettier
- prettierd

## Install

Install [Homebrew](https://brew.sh/) first.

- **macOS:** install Command Line Tools with `xcode-select --install`.
- **Linux:** install your distro's build tools. See [Homebrew's Linux setup](https://docs.brew.sh/Homebrew-on-Linux).
  Install [WezTerm](https://wezterm.org/install/linux.html) separately, or use your existing terminal.

```sh
git clone https://github.com/filiptodosovski/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh --packages
exec zsh -l
```

This installs the packages and plugins and creates the symlinks.
Existing configs are backed up in `~/.dotfiles-backup/`.

Meslo is installed automatically. MonoLisa is optional.
On macOS, allow AeroSpace access in System Settings → Privacy & Security → Accessibility.

## Scripts

- `bin/tmux-sessionizer` — pick a project from `~/Developer` and open its tmux session.
  Session names include a path checksum. Linked to `~/.local/bin/tmux-sessionizer`.
  Use Ctrl-F, then `f` in tmux.
- `scripts/update.sh` — update packages, plugins and language tools. Run `dot update`.
- `scripts/bootstrap.sh --check` — check the setup. Run `dot doctor`.

## Worktrees

From a project, run `wt agent/auth` to create a worktree and open its tmux session.
Use `wt agent/auth main` to start from `main` instead of your current commit.
For `chat-app`, the folder is `chat-app-agent-auth`, beside the original project.
Run your agent CLI there. Install project dependencies if needed.

Switch between projects and worktrees with Ctrl-F, then `f` in tmux.
In the agent worktree, Space gd in Neovim reviews its uncommitted changes.
From the original project, use `:CodeDiff --repo ../chat-app-agent-auth` to review them.
After committing, use `:CodeDiff main...agent/auth` to review the branch.

After reviewing and testing, return to the original project on `main`, with a clean
working tree:

```sh
git merge agent/auth
git worktree remove ../chat-app-agent-auth
git branch -d agent/auth
```

`wt` is linked to `~/.local/bin/wt` by the installer.
