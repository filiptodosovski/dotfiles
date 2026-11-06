# Maintenance and recovery

## Check before updating

```sh
git -C ~/.dotfiles status --short
dot doctor
dot update --dry-run
dot ai --check
```

Review local changes before updating or pulling. `dot doctor` checks the terminal
links, executables, tmux plugins, Neovim servers, and parsers. It doesn't verify
authentication, browser behavior, container availability, or a clean-machine setup.
`dot ai --check` reports AI links, saved settings keys, and Herdr integrations
that need restoring; keys the apps add themselves are ignored. Skills installed
by extension packages are not compared.

`dot update` updates Homebrew/editor tooling and selects the current Node LTS.
Project Node requirements still take precedence; use the project's version file.
`topgrade` is the update-everything command: macOS, apps and casks, CLIs, editor
and agent extensions. Its config (`topgrade/topgrade.toml`) turns off its own
Neovim and tmux steps and runs `dot update` as a final step instead, so the Neovim
lockfile backup and tmux pins still apply. Its container step is off because it
tries to pull locally built Docker images.

## Common problems

- **pnpm global-bin PATH:** `.zprofile` now adds both `$PNPM_HOME/bin` and
  `$PNPM_HOME`; `.zshrc` shares that setup. Run `exec zsh -l`, then `pnpm bin -g`.
  Check the returned directory is in PATH. These files configure Zsh on macOS/Linux.
- **Docker socket missing on the Mac:** start OrbStack with `orb start`, then
  check `docker info`. The updater cannot pull images while the daemon is stopped.
  Don't reset Docker data or switch contexts just to silence the error.
- **Cursor agent launcher cannot find the IDE:** if Cursor IDE is installed on
  macOS, install its official shell command through Cursor, or link its installed
  CLI into a PATH directory. The original Mac has `/opt/homebrew/bin/cursor`
  pointing to `/Applications/Cursor.app/Contents/Resources/app/bin/cursor`.
  Verify `cursor --version`. If you only use Cursor Agent, disable Topgrade's
  Cursor extension step locally instead of installing an unwanted IDE.
- **Starship stash warning:** both saved themes use the escaped literal dollar
  format. Reopen the shell after applying the updated files.

## Backups

Terminal bootstrap saves replaced files under `~/.dotfiles-backup/<timestamp>-*/`.
AI restore saves replaced files under `~/.dotfiles-backup/ai-<timestamp>-*/` with
their paths relative to home. Existing settings can contain private data: keep
these backups private. Backups on the same disk are not protection against disk loss.

To restore, close the affected application, inspect the timestamped backup, and
copy the desired file back to the matching path under home. For example, copy
`<backup>/.pi/agent/settings.json` back to `~/.pi/agent/settings.json`, then restart
Pi. Bootstrap may have backed up a symlink; inspect it before replacing it.
An AI restore only backs up existing files, so remove newly introduced files
individually if undoing a first installation.

`dot update` saves the previous Neovim lockfile before updating plugins. To roll
those plugins back, restore that lockfile and run Neovim's `:Lazy restore`.
This doesn't roll back Homebrew, language servers, parsers, or Node.

Use a separate backup for personal files and verify that one sample file restores.
Keep credentials in the appropriate account/credential manager. Never publish
`~/.pi`, `~/.codex`, `~/.claude`, or `~/.config/herdr` wholesale.

## Public repository checks

Before staging, review new files as well as `git diff`. `.gitignore` is a guardrail:
it does not remove secrets already committed. If a real key is published, revoke
it first; deleting the current file doesn't erase Git history.

If Gitleaks is installed, run `gitleaks dir --redact .` for current files and
`gitleaks git --redact --log-opts=--all .` for local Git history. The generic-key
rule can flag the `entrySha256` values in `ai/skills/sources.json`; compare these
with the actual file hashes before treating them as credentials. Don't broadly suppress
credential rules. This scan doesn't check GitHub issues, remote-only branches,
or files outside the repository.

Keep [GitHub push protection](https://docs.github.com/en/code-security/concepts/secret-security/push-protection)
enabled for your public repositories/account as an additional safeguard.

Skills, extensions, plugins, and hooks are trusted code/instructions with your
user's access. Checksums and lockfiles detect changes; they don't prove upstream
code is safe. Review updates before use. Homebrew packages, Node LTS, tmux
plugins, and language servers update independently of the pinned Pi extensions. The Mac
Brewfile uses WezTerm nightly, so the entire setup is not version-frozen.
