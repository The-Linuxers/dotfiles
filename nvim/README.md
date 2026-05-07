# Neovim Config

Minimal, fast Neovim setup using Neovim 0.12 native features

## Local Development

```sh
alias nvim-dev='NVIM_APPNAME=nvim-dev nvim'
nvim-dev
```

## Plugins

| Plugin | Purpose |
|--------|---------|
| [vague.nvim](https://github.com/vague-theme/vague.nvim) | Colorscheme |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | `mini.completion`, `mini.icons`, `mini.diff`, `mini.files` |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) | Telescope-backed `vim.ui.select` |
| [telescope-env.nvim](https://github.com/LinArcX/telescope-env.nvim) | Environment variable picker |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Git diff / file history UI |
| [nvim-spectre](https://github.com/nvim-pack/nvim-spectre) | Global find & replace |
| [marks.nvim](https://github.com/chentoast/marks.nvim) | Mark management |
| [actions-preview.nvim](https://github.com/aznhe21/actions-preview.nvim) | Preview code actions in Telescope |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP/DAP/linters installer |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Mason + lspconfig bridge |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Auto-install tools |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server configs |

## Keybindings

Leader: `Space`

### Buffer / Window / Tab

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | n | Write buffer |
| `<leader>q` | n | Close window |
| `<leader>Q` | n | Write all & quit |
| `<leader>e` | n | Open **mini.files** file explorer |
| `<C-q>` | n | Open quickfix list |
| `<leader>t` | n, t | Open terminal split |
| `<leader>x` | n, t | Close current tab |
| `<Esc>` | t | Exit terminal mode |
| `<leader>1` … `<leader>8` | n, t | Jump to tab 1–8 |

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `H` | n, x | Start of line (`^`) |
| `L` | n, x | End of line (`$`) |
| `U` | n | Redo |
| `Q` | n | Replay last macro |
| `n` | n | Next search result (centered) |
| `N` | n | Previous search result (centered) |
| `<Esc>` | n | Clear search highlights |
| `<C-h>` | n | Window / tmux left |
| `<C-j>` | n | Window / tmux down |
| `<C-k>` | n | Window / tmux up |
| `<C-l>` | n | Window / tmux right |

### Window Resizing

| Key | Mode | Action |
|-----|------|--------|
| `<M-n>` | n | Increase height (+2) |
| `<M-e>` | n | Decrease height (−2) |
| `<M-i>` | n | Increase width (+5) |
| `<M-m>` | n | Decrease width (−5) |

### Clipboard

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` | n, x | Yank to system clipboard |
| `<leader>p` | n | Paste from system clipboard |

### Find / Replace

| Key | Mode | Action |
|-----|------|--------|
| `S` | n | Replace word under cursor (`:%s/…/…/gI`) |
| `<C-s>` | n, v, x | Literal substitution (`:s/\V`) |
| `<leader>S` | n | Toggle **Spectre** (global find/replace) |
| `<leader>sw` | n | Spectre: search word under cursor |

### Telescope

| Key | Mode | Action |
|-----|------|--------|
| `<leader>f` | n | Find files |
| `<leader>b` | n | Find buffers |
| `<leader>sg` | n | Live grep |
| `<leader>si` | n | Grep string under cursor |
| `<leader>sr` | n | LSP references |
| `<leader>sd` | n | Diagnostics |
| `<leader>sk` | n | Show keymaps |
| `<leader>se` | n | Environment variables |
| `<leader>sa` | n | Code actions (preview via Telescope) |

### Git (Diffview)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gd` | n | Open diffview |
| `<leader>gD` | n | Code review: pick branch vs HEAD |
| `<leader>gc` | n | Close diffview |
| `<leader>gh` | n | File history (current file) |
| `<leader>gH` | n | File history (repo) |

**Inside Diffview:**

| Key | Context | Action |
|-----|---------|--------|
| `<Tab>` / `<S-Tab>` | view, file panel | Next / previous file |
| `j` / `k` | file panel, history | Next / previous entry |
| `<CR>` | file panel, history | Open diff |
| `s` | file panel | Stage / unstage entry |
| `S` | file panel | Stage all |
| `U` | file panel | Unstage all |
| `X` | file panel | Restore entry |
| `R` | file panel | Refresh files |
| `y` | file history | Copy commit hash |
| `<leader>gf` | view, file panel | Toggle file panel |
| `<leader>e` | view | Focus file panel |
| `q` | all | Close diffview |

### Marks

| Key | Mode | Action |
|-----|------|--------|
| `<leader>m` | n | Show all marks (quickfix) |
| `<leader>dm` | n | Delete mark under cursor |
| `<leader>dm` | x | Delete all marks in buffer |

### LSP (buffer-local)

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gr` | n | Go to references |
| `gI` | n | Go to implementation |
| `K` | n | Hover documentation |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n | Code action |
| `<leader>lf` | n | Format buffer |

### Completion (mini.completion)

| Key | Mode | Action |
|-----|------|--------|
| `<Tab>` | i | Next item / expand snippet |
| `<S-Tab>` | i | Previous item |
| `<CR>` | i | Confirm selection |
| `<C-Space>` | i | Force two-step completion |

### Snippets (LuaSnip)

| Key | Mode | Action |
|-----|------|--------|
| `<C-e>` | i, s | Expand or jump forward |
| `<C-J>` | i, s | Jump forward |
| `<C-K>` | i, s | Jump backward |

### Editor Helpers

| Key | Mode | Action |
|-----|------|--------|
| `<leader>r` | n, v, x | Reload buffer (`:edit!`) |
| `<leader>n` | n, v, x | Run normal command (`:norm`) |
| `<leader>lf` | n, v, x | Format buffer |
| `<` / `>` | v | Indent left / right (keeps selection) |
| `<C-f>` | n | Open current directory in Finder |

### mini.files

| Key | Context | Action |
|-----|---------|--------|
| `<CR>` | mini.files buffer | Enter folder / open file |

## Custom Commands

| Command | Description |
|---------|-------------|
| `:PackClean` | Remove unused plugins managed by `vim.pack` |

## LSP Servers (auto-installed)

- `ts_ls` (TypeScript)
- `rust_analyzer` (Rust)
- `clangd` (C/C++)
- `gopls` (Go)
- `lua_ls` (Lua — custom config with `vim` globals)
