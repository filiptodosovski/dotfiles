# AI setup

| Tool | Role | Model |
| --- | --- | --- |
| [Herdr](https://herdr.dev/docs) | Workspace: runs agents in panes, shows who is working or waiting | — |
| [Pi](https://pi.dev) | Agent, OpenAI subscription | `gpt-6.1-sol`, high reasoning |
| [Claude Code](https://code.claude.com/docs) | Agent, Anthropic subscription | Opus, high effort |
| Codex CLI | Agent, OpenAI subscription | `gpt-6.1-sol`, high reasoning |

## Install on a new machine

Everything in one go (also does the terminal setup):

```sh
~/.dotfiles/scripts/bootstrap.sh --packages --ai --dry-run   # preview
~/.dotfiles/scripts/bootstrap.sh --packages --ai
```

`--ai` installs `ai/Brewfile` (Herdr, Python, Codex cask, TypeScript LSP), then
Claude Code (`https://claude.ai/install.sh`) and Pi (`https://pi.dev/install.sh`)
if they're missing. Both official installers put a self-updating launcher in
`~/.local/bin`. It then runs `dot ai --apply`. Agents that are already installed
are left alone.

Then sign in to each agent (Pi `/login`, Codex and Claude on first start).
Pi installs the extensions pinned in `ai/pi/settings.json` the first time it starts.

## `dot ai`

| Command | Does |
| --- | --- |
| `dot ai` | Show what would change. Nothing is written. |
| `dot ai --apply` | Make the changes. Replaced files go to `~/.dotfiles-backup/ai-*`. |
| `dot ai --check` | Exit 1 if anything is out of sync (good after `herdr update`). |
| `dot ai --claude-only` | Limit any of the above to Claude. |

How each file is handled:

- **Linked** (edit either side, it shows in `git diff`): `ai/skills/*`,
  `ai/claude/statusline.py`, `ai/claude/notify.sh`.
- **Merged** (only the keys saved here are enforced; the app's own keys are kept):
  `~/.claude/settings.json`, `~/.pi/agent/settings.json`.
- **Created if missing**, never overwritten: `~/.codex/config.toml`,
  `~/.codex/keybindings.json`. `dot ai` prints a note if the portable keys differ.
- **Herdr hooks** are installed by `herdr integration install` for each agent, so
  they always match the installed Herdr version.

## Skills

Shared by Pi (`/skill:name`) and Claude (`/name`). Full text loads only when used.

| Skill | Use | Invocation |
| --- | --- | --- |
| `impeccable` | UI design, critique, polish | Automatic or manual |
| `vercel-react-best-practices` | React / Next.js performance | Automatic or manual |
| `vercel-composition-patterns` | React component structure | Automatic or manual |
| `codebase-design` | Module and interface design | Automatic or manual |
| `grill-me` | Interview you about a plan before building (uses `grilling`) | Manual: `/grill-me` |

To add one, put its folder in `ai/skills/`, record its repo and commit in
`ai/skills/sources.json`, and run `dot ai --apply`. To remove one, delete the
folder and run `dot ai --apply`; the dangling link is cleaned up. Impeccable
downloads its engine into `ai/skills/impeccable/scripts/bin/` (git-ignored).

## Claude extras

- **Status line:** `folder [branch ±changed] · model/effort | ctx% · cache% · 5h% · wk%`.
- **Sounds:** Glass when a reply finishes; Ping plus a banner when Claude waits for
  you. Test with `sh ~/.claude/notify.sh done` or `… input`. Herdr's own Claude
  sounds are muted in `~/.config/herdr/config.toml` to avoid doubles.
- **Plugins:** `typescript-lsp` (go-to-definition and type errors for TS/JS).
- **Permissions:** read-only git, `rg`, `ls`, `pnpm test/lint/typecheck` run
  without asking; `rm -rf`, force push, and `reset --hard` always ask. The Read
  tool can't open `.env*`, `~/.ssh`, `~/.aws`, `~/.config/gh`, or agent `auth.json` files.
- **Sandbox:** Bash commands run in Claude's OS sandbox, which blocks the same
  paths, so `cat .env` is refused too. `git fetch/pull/push`, `gh`, `docker`, and
  `open` are excluded because they break inside the macOS sandbox; they run with
  normal access. If another command fails with a sandbox error, add it to
  `sandbox.excludedCommands` in `ai/claude/settings.json` and run `dot ai --apply`.

## Not saved here

Logins, API keys, sessions, history, project trust, and Herdr's own config.
Never copy `~/.claude`, `~/.pi`, `~/.codex`, or `~/.config/herdr` into this repo.
