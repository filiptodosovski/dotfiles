# Neovim cheat sheet

Leader is **Space**. This sheet describes the cleaned configuration, based on
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

For agent worktrees, run wt agent/auth in a project terminal. In that worktree,
Space gd reviews uncommitted changes. From the original project, use
:CodeDiff --repo ../chat-app-agent-auth. After committing, use
:CodeDiff main...agent/auth to review the branch before merging.

Gitsigns shows changed-line markers and inline blame. LazyGit handles commits,
branches, staging, pulling and pushing. Select a conflicted file in CodeDiff to
resolve it: Space co accepts ours, Space ct theirs, Space cb both, and ]x/[x moves
between conflicts.

## Maintenance

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
