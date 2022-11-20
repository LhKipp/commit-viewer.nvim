commit-viewer.nvim
======

A git commit browser.

## Installation

```vim
Plug 'tpope/vim-fugitive'
Plug 'LhKipp/commit-viewer.nvim'
```

Don't forget to call setup :smirk:
```lua
require('commit-viewer').setup{}
```

## Usage

- `:CV` to open commit browser
    - You can pass git log options to the command, e.g. :GV -S foobar -- plugins.
- `:CV!` will only list commits that affected the current file
- `require'commit-viewer'.open(list_with_log_arguments)` same as `:CV`

Buffers opened by `CV` are of filetype `CV`. To add mappings to this buffer add a `ftplugin/CV.lua` to your configuration.
```
-- Example ftplugin/CV.lua
local kbs = require 'commit-viewer.kb_funcs'

vim.keymap.set({ 'n', 'v' },
    '<CR>',
    kbs.kb_open_commit({ window_layout = "horizontal", window_resize = "+7" }),
    { buffer = true })
vim.keymap.set({ 'n', 'v' },
    'O',
    kbs.kb_open_commit({ new_tab = true }),
    { buffer = true })


-- <sha> is replaced with the git-sha of the current line
vim.keymap.set('n', 're', kbs.kb_exe("git", { "reset", "<sha>" }), { buffer = true })
vim.keymap.set('n', 'rb', kbs.kb_feedkeys(":Git rebase -i <sha><CR>", true), { buffer = true })
-- The cursor is placed where <cursor> is
vim.keymap.set('n', '.', kbs.kb_feedkeys(":Git <cursor> <sha>"), { buffer = true })
```

### Configuration

```
-- Default values are being shown
require'commit-viewer'.setup{
    reuse_buffer = false -- Whether to reuse an existing git-log buffer
}
```


