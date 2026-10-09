# Dotfiles cheat sheet

Neovim leader is **Space**. tmux prefix is **Ctrl-F**.
This sheet describes the cleaned configuration, based on
February 24 (`bac9d5d`) custom mappings with modern completion and LSP interfaces.

## Search and navigation

| Keys | Action |
| --- | --- |
| Ctrl-P, Space pp | Find files with Telescope |
| Space pf | Find Git-tracked files |
| Space pa | Live text search |
| Space ps | Prompt for a literal text search |
| Space pb | Choose an open buffer |
| Space pr | Recent files |
| Space vh | Search help |
| Shift-P | Search commands |
| Ctrl-B | Reveal active file in Neo-tree on the right |
| Ctrl-Y (Normal mode) | Toggle Neo-tree |
| Space rv | Reveal active file in Neo-tree |
| Space pv | Open built-in file browser (netrw) |
| Shift-H, Shift-L | Previous / next buffer |
| Space bdd | Close buffer |
| Space bda | Close other buffers |

Arrow keys remain disabled in Normal and Insert modes, as in your earlier setup.
Use h/j/k/l in Normal mode. Ctrl-D/Ctrl-U scroll while keeping the cursor centered.

## Code and diagnostics

| Keys | Action |
| --- | --- |
| K | Hover documentation |
| gd | Definition |
| gD | Declaration |
| gi | Implementation |
| go | Type definition |
| gs | Signature help |
| Space rn | Rename symbol |
| Space ca | Code action |
| Space vrr | List references through LSP |
| Space cV | Select TypeScript version (vtsls buffers) |
| gr | References in Trouble |
| Space q | Diagnostic popup |
| ]d, [d | Next / previous diagnostic |
| Space xx | Toggle all diagnostics in Trouble |
| Space xw | Toggle current-buffer diagnostics |
| Space xq, Space xl | Quickfix / location list |
| Space h | Clear search highlights |
| Space k, Space j | Next / previous location-list item |

## Completion, formatting and editing

| Keys | Action |
| --- | --- |
| Ctrl-Space | Open completion menu |
| Ctrl-n, Ctrl-p | Next / previous completion |
| Ctrl-y | Select and accept completion |
| Enter | Accept selected or first completion; otherwise ordinary Enter |
| Tab, Shift-Tab | Move through snippet placeholders |
| Space f, :Format | Format through Conform |
| F3 (Visual) | Format selection when LSP is attached |
| gcc | Toggle line comment using built-in commenting |
| gc + motion, visual gc | Toggle comments for a region |
| sa + motion + surround | Add surrounding quotes/brackets |
| sd + surround | Delete surrounding quotes/brackets |
| sr + old + new | Replace surrounding quotes/brackets |
| Space s | Open substitution for the word under the cursor |
| Space +, Space - | Increment / decrement number |
| Visual J, K | Move selected lines |
| Space y, Space Y | Copy to system clipboard |
| Space P | Paste from system clipboard |
| Space d | Delete without replacing clipboard/register contents |
| Visual Space po | Replace selection without overwriting the paste register |
| Space u | Toggle visual undo history |
| Space cx | Make current file executable |
| Space ra | Reload buffers |

mini.ai enhances a/i text objects, including arguments, function calls and tags.
mini.pairs inserts matching quotes/brackets. Autotag closes and renames HTML/JSX tags.

Formatting runs on save. Go organizes imports before formatting through gopls,
falling back to gofmt when no gopls client is attached. Web files use project
Prettier; Python uses Ruff; Lua uses StyLua. Inspect availability with :ConformInfo.

## Git

| Keys | Action |
| --- | --- |
| Space lg | LazyGit |
| Space gh | CodeDiff: current-file history |
| Space gp | Preview changed hunk |
| Space gd | CodeDiff: review repository changes |
| Space gD | CodeDiff: current file against HEAD |

Inside CodeDiff:

| Keys | Action |
| --- | --- |
| Enter (file list) | Open selected diff |
| ]c / [c | Next / previous hunk |
| ]f / [f | Next / previous file |
| Space hs / Space hu | Stage / unstage hunk |
| - | Stage / unstage file |
| t | Switch side-by-side / inline layout |
| g? | Show all shortcuts |
| q | Close diff view |

Changes refresh automatically. Use :CodeDiff history for repository history.

Gitsigns shows changed-line markers and inline blame. LazyGit handles commits,
branches, staging, pulling and pushing. Select a conflicted file in CodeDiff to
resolve it: Space co accepts ours, Space ct theirs, Space cb both, and ]x/[x moves
between conflicts.

## tmux

Press Ctrl-F, release it, then press the next key.

| Keys after Ctrl-F | Action |
| --- | --- |
| f | Pick a project from ~/Developer and open its session |
| s | Choose a running session |
| ( / ) | Previous / next session |
| d | Detach; leave programs running |
| c | New window |
| , | Rename window |
| 1–9 | Select window |
| \| / - | Split horizontally / vertically |
| H / J / K / L | Select pane left / down / up / right |
| h / j / k / l | Resize pane |
| m | Toggle pane zoom |
| o | Open dotfiles session |
| g | Open LazyGit in a new window |
| r | Reload tmux configuration |

To kill another session: Ctrl-F, then s; select the **session row**, press x,
then y to confirm. This stops its programs but leaves the worktree folder and branch.
To kill the current session from its terminal, run `tmux kill-session`.

Session names include a path checksum so same-named folders stay separate.
Set PROJECT_DIR to change the picker directory. Both helpers are linked in ~/.local/bin.

## Agent worktrees

From a project terminal:

```sh
wt agent/auth       # Start from your current commit
wt agent/auth main  # Alternatively, start from local main
```

Choose one command. wt creates a new branch and a sibling folder, then opens its
tmux session. For chat-app, the folder is chat-app-agent-auth. Reopen it through
Ctrl-F, then f. Run your agent CLI there and install project dependencies if needed.
Uncommitted edits and ignored files, including dependencies and .env files, aren't copied.

In the agent worktree, Space gd reviews uncommitted changes. From Neovim in the
original project:

```vim
:CodeDiff --repo ../chat-app-agent-auth
```

After committing the agent's work, review its branch:

```vim
:CodeDiff main...agent/auth
```

After reviewing and testing, return to the original project on main with a clean
working tree:

```sh
git merge agent/auth
git worktree remove ../chat-app-agent-auth
git branch -d agent/auth
```

Use your actual folder and branch names. `git worktree list` lists the worktrees.

## Shell

- fnm selects Node versions; uv manages Python projects.
- Atuin searches command history; zoxide jumps between directories with z.
- fzf-tab provides fuzzy Tab completion; lg opens LazyGit.
- prompt-core / prompt-languages switch Starship profiles.

For a Node project, keep one .node-version or .nvmrc in the project root.
fnm switches automatically when entering the project. Once the selected Node
version is right for that project, record it with `node --version > .node-version`
and commit the file. Use `fnm install` if its recorded version isn't installed.

## Setup on another computer

Follow the installation commands in [README](../README.md).

- Install Homebrew first.
- macOS: install Command Line Tools with `xcode-select --install`.
- Linux: install your distro's build tools; see [Homebrew's Linux setup](https://docs.brew.sh/Homebrew-on-Linux).
  Install [WezTerm](https://wezterm.org/install/linux.html) separately or use your existing terminal.
- Meslo is installed by bootstrap with --packages; MonoLisa is optional.
- macOS: allow AeroSpace in System Settings → Privacy & Security → Accessibility.

The installer links zsh, tmux, Neovim, WezTerm, Starship and the bin helpers.
AeroSpace is linked on macOS only. Existing configs are backed up in ~/.dotfiles-backup/.

| Command from the dotfiles folder | Action |
| --- | --- |
| ./scripts/bootstrap.sh --packages | Install packages, link configs and install plugins/servers/parsers |
| ./scripts/bootstrap.sh --links-only | Create links without installing tools |
| ./scripts/bootstrap.sh --dry-run | Preview the setup |
| exec zsh -l | Reload the shell |

## Maintenance

- dot doctor checks symlinks, tools, plugins, parsers and language servers.
- dot update --dry-run previews updates.
- dot update updates Brewfile packages, Node LTS/default, Neovim tools and unpinned tmux plugins.
  It also refreshes WezTerm nightly on macOS; Linux terminals are managed separately.
- Updates back up the Neovim lockfile in ~/.dotfiles-backup/.
- The tmux theme stays pinned to v1.9.0; Blink tracks v1 releases.
- :Lazy opens the plugin manager; :Lazy restore uses the lockfile's revisions.
- :Lazy clean removes installed plugins no longer configured.
- :Mason opens the language-server installer.
- :checkhealth vim.lsp checks language-server configuration.
- :ConformInfo lists formatters and whether they are available.
- Pause after a shortcut prefix for which-key hints.

Removed shortcuts: Harpoon (Space h...), tests (Space t...), Markdown preview
(Space mp), HealthTS (Space ch), repeated grep (Space pr), and later Git aliases
(Space gg/gc/gf/gs). Removed plugins stay removed. Blink, native comments and
native snippets retain their defaults; the restored keys above cover the
personal mappings for retained features.
