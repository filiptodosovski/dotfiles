# Neovim Productivity Cheat Sheet

## Daily flow (TS-focused)
- Find file: `<C-p>` or `<leader>ff`
- Grep project: `<leader>pa` or `<leader>fg`
- Open git files: `<leader>pf`
- Format file: `<leader>f`
- Quick diagnostics panel: `<leader>xx`

## LSP
- Definition: `gd`
- References: `gr`
- Hover: `K`
- Rename symbol: `<leader>rn`
- Code action: `<leader>ca`
- Signature help: `gs`
- Leader definition: `<leader>ld`
- Leader implementation: `<leader>li`
- Leader references panel: `<leader>lr`

## Diagnostics
- Trouble diagnostics: `<leader>xx`
- Buffer-only diagnostics: `<leader>xw`
- Next diagnostic: `]d`
- Prev diagnostic: `[d`
- Cursor diagnostic float: `<leader>q`

## Search / Telescope
- Find files: `<C-p>` / `<leader>ff`
- Live grep: `<leader>pa` / `<leader>fg`
- Git files: `<leader>pf`
- Buffers: `<leader>fb`
- Recent files: `<leader>fr`
- Help tags: `<leader>vh`

## Harpoon (fast file hopping)
- Add current file: `<leader>ha`
- Open list/menu: `<leader>hh`
- Next/prev: `<leader>hn` / `<leader>hp`
- Jump to slot: `<leader>h1` `<leader>h2` `<leader>h3` `<leader>h4`

## Buffers
- Next buffer: `<S-l>`
- Prev buffer: `<S-h>`
- Close current buffer: `<leader>bdd`
- Close others: `<leader>bda`

## Useful existing mappings
- Reveal in Neo-tree: `<leader>rv`
- Toggle Neo-tree: `<C-Y>`
- Reload all buffers: `<leader>ra`
- Force reload all buffers: `<leader>rf`
- Make file executable: `<leader>cx`

## Recommended habit loop
1. Open 2-4 active files and pin them with Harpoon.
2. Use Telescope for discovery, Harpoon for repeated jumps.
3. Keep diagnostics in Trouble (`<leader>xx`) while fixing.
4. Run `<leader>f` before commit/save checkpoints.
