# Neovim Keybind Cheat Sheet

## Leader
- Leader key: `<Space>`

## Disabled keys
- Normal: `<Up>`, `<Down>`, `<Left>`, `<Right>` -> disabled
- Insert: `<Up>`, `<Down>`, `<Left>`, `<Right>` -> disabled
- Normal: `Q` -> disabled

## Editing and movement
- Visual line move down/up: `J` / `K` (in visual mode)
- Join line without cursor jump: `J` (normal mode)
- Half-page down/up centered: `<C-d>` / `<C-u>`
- Next/prev search centered: `n` / `N`
- Insert `Ctrl-c` behaves like escape: `<C-c>`
- Replace current word globally: `<leader>s`

## Clipboard and text ops
- Yank to system clipboard: `<leader>y` (normal/visual), `<leader>Y` (line)
- Paste from system clipboard: `<leader>P` (normal/visual)
- Delete without yanking: `<leader>d` (normal/visual)
- Visual paste without clobbering register: `<leader>po`

## File and buffer
- Open netrw explorer: `<leader>pv`
- Reload all buffers: `<leader>ra`
- Force reload all buffers: `<leader>rf`
- Next/prev buffer: `<S-l>` / `<S-h>`
- Delete current buffer: `<leader>bdd`
- Delete all but current: `<leader>bda`

## Search and Telescope
- Find files: `<C-p>` or `<leader>ff`
- Git files: `<leader>pf`
- Grep prompt: `<leader>ps`
- Live grep: `<leader>pa` or `<leader>fg`
- Buffers picker: `<leader>fb`
- Recent files: `<leader>fr`
- Help tags: `<leader>vh`
- Command picker: `<S-p>`
- Git file history: `<leader>gh`

## Neo-tree
- Toggle tree: `<C-Y>`
- Reveal current file: `<leader>rv`
- Reveal right (plugin key): `<C-b>`

## LSP and diagnostics
- Hover: `K`
- Definition: `gd` or `<leader>ld`
- Declaration: `gD`
- Implementation: `gi` or `<leader>li`
- Type definition: `go`
- Signature help: `gs`
- Diagnostic float: `gl` or `<leader>q`
- Next/prev diagnostic: `]d` / `[d`
- Rename symbol: `<leader>rn`
- Code action: `<leader>ca`
- References panel (Trouble): `<leader>lr` or `gr`
- Format: `<leader>f` or `<F3>`
- Toggle `lsp_lines`: `<leader>e`
- Select TS workspace version: `<leader>cV`

## Trouble
- Diagnostics panel: `<leader>xx`
- Buffer diagnostics: `<leader>xw`
- Quickfix list: `<leader>xq`
- Location list: `<leader>xl`

## Git
- Preview hunk: `<leader>gp`
- Stage hunk: `<leader>gs`
- Open LazyGit: `<leader>gg` or `<leader>lg`
- LazyGit current file: `<leader>gc`
- LazyGit filter current file: `<leader>gf`

## Harpoon
- Add file: `<leader>ha`
- Menu: `<leader>hh`
- Next/prev: `<leader>hn` / `<leader>hp`
- Jump file 1..4: `<leader>h1` `<leader>h2` `<leader>h3` `<leader>h4`

## Testing
- Test nearest: `<leader>tn`
- Test file: `<leader>tf`
- Test last: `<leader>tl`
- Visit test window: `<leader>tv`

## Sessions and undo
- List sessions: `<leader>sl`
- New session: `<leader>sn`
- Update session: `<leader>su`
- Delete session: `<leader>sd`
- Toggle undo tree: `<leader>u`

## Utility commands
- Clear search highlight: `<leader>nh`
- Increment/decrement number: `<leader>+` / `<leader>-`
- Next/prev location list item: `<leader>k` / `<leader>j`
- Make file executable: `<leader>cx`
- TS health checks: `<leader>ch`
- Commands: `:Format`, `:HealthTS`
