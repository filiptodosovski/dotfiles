# Dotfiles

My Zsh, tmux, WezTerm, Starship, Neovim, and optional AI setup.
MonoLisa is the preferred font; Meslo Nerd Font provides the fallback and icons.

## Platforms

| Platform | Setup |
| --- | --- |
| macOS | Homebrew bootstrap; verified on my Apple Silicon Mac. AeroSpace is Mac-only. |
| Linux | Homebrew bootstrap on a supported 64-bit distribution; install WezTerm separately. |

Linux restore tests run in an isolated container. WezTerm's macOS/Linux branches
are tested with a mock; a complete fresh Linux desktop install still needs
verification on the target machine. Homebrew and downloaded tools have their own
OS/architecture requirements; this is not an installer for every machine.

## Install

On macOS, install Apple's command-line tools (`xcode-select --install`). On Linux,
install your distro's compiler/build tools, Git, curl, file, and procps; Ubuntu:

```sh
sudo apt update
sudo apt install build-essential procps curl file git
```

Install [Homebrew](https://brew.sh/) and follow its PATH instructions, then:

```sh
git clone https://github.com/filiptodosovski/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh --packages --ai --dry-run
./scripts/bootstrap.sh --packages --ai
exec zsh -l
dot doctor
```

This installs the Brewfile tools, current Node LTS, tmux plugins, and locked Neovim
plugins plus language servers/parsers. It links configs and backs up replaced
files under `~/.dotfiles-backup/`. Review existing configs first. Internet access
is required; initial Neovim setup can take a while. It does not change your login
shell automatically. Install licensed MonoLisa yourself; font files are not included.

`--ai` adds Claude Code, Pi, Codex, Herdr, the shared skills, and agent settings
(see [AI setup](docs/ai.md)); leave it out for terminal/editor only.
Already have the tools? Omit `--packages`. To create only config links without
downloading anything, use `--links-only`. `--dry-run` previews either choice.
Use the `~/.dotfiles` clone location: some tmux shortcuts use that path.

For a Linux desktop, install [WezTerm](https://wezterm.org/install/linux.html) separately.

## Daily commands

- `tmux-sessionizer` — choose a project; in tmux, Ctrl+F then `f`.
- `wt <branch> [base]` — create a worktree and open its tmux session.
- `dot doctor` — check links, tools, plugins, parsers, and language servers.
- `topgrade` — update everything (macOS, apps, CLIs), including `dot update`.
- `dot update --dry-run` — preview terminal/editor updates; `dot update` applies them.
- `dot ai` — preview the optional AI restore; no changes by default.
- `dot ai --apply` — link AI skills and scripts, merge settings, update Herdr hooks.
- `dot ai --check` — report AI settings, links, or Herdr hooks that need restoring.

## AI and recovery

[AI setup](docs/ai.md) covers Herdr, Pi, Claude Code, and Codex, the shared
skills, and the `dot ai` command.
It is optional and separate from terminal setup; Python 3.10+ is required for
the restore script and its tests. Credentials and account access are configured
separately. Existing Codex config is preserved.

For Claude Code only, use `python3 scripts/ai-setup.py --claude-only --apply`.
This sets up preferences and permission rules, the status line, macOS sounds and
banners, the shared skills, and Herdr's Claude hook; it leaves Pi and Codex alone. Preview first by
omitting `--apply`. See the AI guide for usage and backups.

[Maintenance and recovery](docs/maintenance.md) covers backups, updates,
pnpm/Docker/Cursor troubleshooting, and public-repository safety.

## Before committing

```sh
python3 -B -m unittest discover -s tests -v
bash -n scripts/bootstrap.sh scripts/update.sh bin/wt bin/tmux-sessionizer
DOTFILES_DIR="$PWD" nvim -l tests/wezterm-config.lua
git diff --check
git status --short
git diff --cached
```

Review new files too: `git diff` alone does not show untracked files. Never copy
whole live AI directories, credentials, sessions, licensed fonts, or backups here.
Setup scripts never commit or push. GitHub Actions runs a Gitleaks secret scan over the full history, the Python
tests, and shell syntax checks on Ubuntu and macOS, plus the WezTerm config test on Ubuntu; it does
not perform a complete machine installation.

Installers that append to `~/.zshrc` or `~/.zprofile` (PATH lines and similar)
would edit this repo through the symlink. Move those lines into the untracked
`~/.zshrc.local` / `~/.zprofile.local`, which are sourced last.
