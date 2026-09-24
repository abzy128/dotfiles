# Neovim Config

A modular Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), migrated to Neovim 0.12+ native APIs.

## Directory Structure

```
~/.config/nvim/
├── init.lua                  # Entry point
├── lazy-lock.json            # Plugin version lockfile
└── lua/
    └── abzy/
        ├── options.lua       # Vim options
        ├── keybinds.lua      # Global keybindings
        ├── cmds.lua          # Autocommands
        ├── lazy.lua          # Lazy.nvim bootstrap
        ├── lsp_servers.lua   # Per-server vim.lsp.config() overrides
        ├── health.lua        # :checkhealth abzy
        └── plugins/
            ├── lsp.lua           # Mason + native LSP setup
            ├── completion.lua    # blink.cmp
            ├── autoformat.lua    # conform.nvim
            ├── telescope.lua
            ├── theme.lua
            ├── treesitter.lua
            ├── whichkey.lua
            ├── gitsigns.lua
            ├── alpha.lua
            ├── mini.lua
            ├── todo-comments.lua
            ├── editing.lua       # vim-sleuth, nvim-autopairs, indent-blankline
            ├── dap.lua           # Debugger
            ├── linting.lua       # nvim-lint
            └── neotree.lua       # File tree
```

## Plugin Manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — lazy-loads plugins for fast startup.

## Plugins

### Core

| Plugin | Purpose |
|--------|---------|
| nvim-treesitter | Syntax highlighting (bash, c, diff, html, lua, markdown, vim, hyprlang) |
| blink.cmp | Completion engine (LSP, path, snippets, buffer) |
| conform.nvim | Format on save (LSP fallback, disabled for C/C++) |
| telescope.nvim | Fuzzy finder (files, grep, buffers, diagnostics, etc.) |
| kanagawa.nvim | Colorscheme |
| which-key.nvim | Keybinding hints (delay = 0) |
| gitsigns.nvim | Git hunk indicators, blame, diff |
| alpha-nvim | Startup dashboard |
| mini.nvim | mini.ai, mini.surround, mini.statusline |
| todo-comments.nvim | Highlight TODO/FIXME (no gutter signs) |

### Editing

| Plugin | Purpose |
|--------|---------|
| vim-sleuth | Auto-detect indentation |
| nvim-autopairs | Auto-close brackets/quotes |
| indent-blankline.nvim | Indentation guides |

### Dev Tools

| Plugin | Purpose |
|--------|---------|
| nvim-dap + nvim-dap-ui + nvim-dap-go | Debugger |
| nvim-lint | Linting (markdownlint) |
| neo-tree.nvim | File tree explorer |

### Support

mason.nvim, mason-lspconfig.nvim, mason-tool-installer.nvim, fidget.nvim, lazydev.nvim, telescope-fzf-native.nvim, telescope-ui-select.nvim, nvim-web-devicons, plenary.nvim, nvim-nio

## LSP

Uses Neovim 0.12 native LSP (`vim.lsp.config` + `vim.lsp.enable`). Mason installs servers; mason-lspconfig enables them automatically. Per-server overrides live in `lsp_servers.lua`.

| Server | Language |
|--------|----------|
| clangd | C/C++ |
| gopls | Go |
| pyright | Python |
| rust_analyzer | Rust |
| ts_ls | TypeScript/JavaScript |
| csharp_ls | C# |
| jdtls | Java |
| hyprls | Hyprland config |
| lua_ls | Lua (callSnippet = "Replace") |

Tool also ensured: `stylua`

## Key Mappings

**Leader:** `<Space>`

### General

| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlight |
| `<leader>ee` | Open netrw |
| `<leader>q` | Diagnostic quickfix list |
| `<C-h/j/k/l>` | Navigate splits |
| `<Esc><Esc>` (terminal) | Exit terminal mode |

### LSP (on attach)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename |
| `<leader>ca` | Code actions |
| `<leader>th` | Toggle inlay hints |

### Telescope (`<leader>s`)

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep current word |
| `<leader>sd` | Diagnostics |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>ss` | Telescope builtins |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Fuzzy search current buffer |
| `<leader>s/` | Search in open files |
| `<leader>sn` | Search nvim config |

### Git (`<leader>h`, `<leader>t`)

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next/prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hu` | Undo stage |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff index |
| `<leader>hD` | Diff last commit |
| `<leader>tb` | Toggle line blame |
| `<leader>tD` | Toggle deleted |

### Debug (`<F*>`, `<leader>b`)

| Key | Action |
|-----|--------|
| `<F5>` | Start/continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle DAP UI |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |

### File Navigation

| Key | Action |
|-----|--------|
| `\` | Toggle Neo-tree |
| `<leader>ee` | Open netrw |

### Completion (insert mode)

blink.cmp default preset — see `:help blink-cmp-keymap` for full bindings.

### Format

| Key | Action |
|-----|--------|
| `<leader>f` | Format buffer |

## Options

| Option | Value |
|--------|-------|
| Line numbers | Absolute + relative |
| Sign column | Always |
| Cursor line | Enabled |
| Mouse | All modes |
| Showmode | Off (in statusline) |
| Listchars | `tab:» `, `trail:·`, `nbsp:␣` |
| Inccommand | `split` (live preview) |
| Scrolloff | 10 |

## Autocommands

| Event | Action |
|-------|--------|
| TextYankPost | Highlight yanked text |
| LspAttach | Set up LSP keymaps, document highlight |
| CursorHold/I | Highlight symbol references |
| BufEnter, BufWritePost, InsertLeave | Run linters |

## External Dependencies

- `git`
- `make` (for telescope-fzf-native)
- `unzip`
- `rg` (ripgrep)
- Nerd Font (optional, but assumed: `vim.g.have_nerd_font = true`)
