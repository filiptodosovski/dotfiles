# Dotfiles

Reproducible macOS development environment centered on Neovim, TypeScript, and Python.

The terminal presentation is intentionally kept in the existing WezTerm, Starship, tmux,
and AeroSpace configuration files.

## Bootstrap

Install Apple's Command Line Tools and [Homebrew](https://brew.sh/) first. Clone the
repository, then run the idempotent bootstrap script:

```bash
xcode-select --install
git clone https://github.com/filiptodosovski/dotfiles.git ~/.dotfiles
~/.dotfiles/scripts/bootstrap.sh --packages
exec zsh -l
```

Omit `--packages` to create only the symlinks and sync Neovim. Existing targets that do
not already resolve to this repository are moved to `~/.dotfiles-backup/<timestamp>/`
before replacement. The script links complete configuration directories, installs TPM
and its plugins, links the tracked `tmux-sessionizer`, and waits for Neovim parsers and
language servers to finish installing.

Inspect or verify without changing the machine:

```bash
~/.dotfiles/scripts/bootstrap.sh --dry-run
~/.dotfiles/scripts/bootstrap.sh --check
```

MonoLisa is licensed and is not stored in this repository. Install
`MonoLisa-Regular.ttf` in `~/Library/Fonts` before starting WezTerm. The bootstrap check
reports when it is missing; Meslo remains the icon and missing-glyph fallback.

The `Brewfile` contains the reproducible core toolchain. Mason owns Neovim's editor
language servers; Homebrew provides the general CLI tools (including Ruff and ty for
shell workflows) and the Tree-sitter CLI. Package bootstrap grants trust only to the
specific AeroSpace cask, not its entire third-party tap. It also installs the current
Node LTS through fnm and makes it the default.

## JavaScript and TypeScript

Completion is enabled by `blink.cmp`, backed by the active TypeScript language server,
buffer words, paths, and snippets. VTSLS is used for current projects. If a project has
TypeScript 7 or newer, Neovim automatically selects the native TypeScript LSP instead;
the two servers do not run together.

Completion keys (unchanged):

- Show completion/docs: `Ctrl-Space`
- Next/previous item: `Ctrl-n` / `Ctrl-p`
- Accept selected item: `Ctrl-y`
- Accept/fallback: `Enter`

VTSLS prefers the project's TypeScript version and keeps auto-imports, function-call
completion, inlay hints, and move-to-file actions enabled. ESLint runs through its LSP,
so monorepo and project-local configuration are respected.

Formatting uses the first available formatter (`prettierd`, then `prettier`) and runs on
save. Manual formatting remains `<leader>f`, `<F3>`, or `:Format`.

`:HealthTS` / `<leader>ch` detects pnpm, Bun, Yarn, or npm from `packageManager` and
lockfiles. It runs available non-mutating `format:check`, `lint`, `typecheck`, and `test`
scripts.

## Python

The Python path is intentionally small and modern:

- `uv` for Python versions, virtual environments, dependencies, and scripts
- `ruff` for linting, fixes, import sorting, and formatting
- `ty` for type checking and editor language intelligence

Start a project with:

```bash
uv init
uv add <package>
uv run python main.py
uv run ruff check .
uv run ty check
```

Neovim attaches Ruff and ty automatically. Ruff owns diagnostics/fixes and formatting;
ty owns types and hover information. Python defaults to four-space indentation unless a
project's EditorConfig overrides it.

## Maintenance

```bash
dot doctor  # show required tools and their resolved paths
dot update  # Homebrew upgrade + Neovim plugin/parser/Mason registry sync
```

Starship profiles remain unchanged:

```bash
dot prompt-core
dot prompt-languages
```

## Neovim behavior

- Tree-sitter uses its Neovim 0.12 `main` API and installs the configured parsers.
- Swap, persistent undo, and session recovery are enabled. Session state lives under
  Neovim's state directory rather than inside this repository.
- Undo state is private to the user. Swap and persistent undo are disabled for common
  secret files such as `.env`, `.dev.vars`, private keys, and credentials; persistent
  backups remain disabled globally.
- Trailing whitespace is removed on save except in Markdown, diffs, and commit messages.
- Formatting uses project tools where available and LSP fallback otherwise.
- [Full key reference](nvim/CHEATSHEET.md) and [short reference](nvim/CHEATSHEET_SHORT.md)

No keybindings were added or removed in this modernization pass.
