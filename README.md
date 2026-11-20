# tasker.nvim

Neovim plugin for tasklist documents

## Features

- **Titles & Subtitles**: Easily create centered titles and subtitles with decorative borders.
- **Task Management**: Quickly create task items with checkboxes `- [ ]`.
- **Progress Tracking**: Mark tasks as done `- [X]` or unmark them.
- **Visual Mode**: Apply changes to multiple lines at once in visual mode.
- **Floating Terminal**: Persistent floating terminal for quick task execution.

## Configuration

The plugin can be configured with the `setup` function.

```lua
require('tasker').setup({
    width = 50, -- Width for titles and subtitles (default: 50)
    target_file = "todo.md" -- Default file for Td command (default: "todo.md")
})
```

## Usage

The plugin exposes the following functions which can be mapped to keys:

- `makeTitle`: Converts the current line into a centered title.
- `makeSubTitle`: Converts the current line into a centered subtitle.
- `makeItem`: Converts line(s) into task items. Works in both normal and visual mode.
- `markItem`: Marks task item(s) as done `- [X]`.
- `unmarkItem`: Unmarks task item(s) `- [ ]`.

### Commands

- `:Td`: Opens the configured `target_file` in a floating window.
- `:Tt`: Toggles a persistent floating terminal.

## Installation

### Using `vim.pack`

``` lua
vim.pack.add {
  { src = 'https://github.com/tehritarun/tasker.nvim' },
}
local tasker = require 'tasker'

-- Optional: Configure width
require('tasker').setup { width = 60, target_file = '~/projects/snippets/todo.md' }

-- Keymaps
vim.keymap.set('n', '<leader>td', '<cmd>Td<cr>', { desc = 'Open Todo' })
vim.keymap.set({ 'n', 't' }, '<leader>tt', '<cmd>Tt<cr>', { desc = '[T]oggle [T]erminal' })

vim.keymap.set('n', '<leader>ct', tasker.makeTitle, { desc = 'Make Title' })
vim.keymap.set('n', '<leader>cs', tasker.makeSubTitle, { desc = 'Make Subtitle' })

vim.keymap.set({ 'n', 'v' }, '<leader>cc', tasker.makeItem, { desc = 'Make item' })
vim.keymap.set({ 'n', 'v' }, '<leader>cm', tasker.markItem, { desc = 'Mark item' })
vim.keymap.set({ 'n', 'v' }, '<leader>cu', tasker.unmarkItem, { desc = 'Unmark item' })
-- Keymaps for markdown table
vim.keymap.set('v', '<leader>mt', tasker.CreateMarkdownTable, { desc = 'Convert to markdown' })
```

### Using `lazy.nvim`

``` lua
{
  'tehritarun/tasker.nvim',
  config = function()
    local tasker = require('tasker')

    -- Optional: Configure width
    tasker.setup { width = 60, target_file = '~/projects/tasker/todo.md' }

    -- Keymaps for tasker
    vim.keymap.set('n', '<leader>ct', tasker.makeTitle, { desc = 'Make Title' })
    vim.keymap.set('n', '<leader>cs', tasker.makeSubTitle, { desc = 'Make Subtitle' })

    vim.keymap.set({ 'n', 'v' }, '<leader>cc', tasker.makeItem, { desc = 'Make item' })
    vim.keymap.set({ 'n', 'v' }, '<leader>cm', tasker.markItem, { desc = 'Mark item' })
    vim.keymap.set({ 'n', 'v' }, '<leader>cu', tasker.unmarkItem, { desc = 'Unmark item' })
    -- Keymaps for markdown table
    vim.keymap.set('v', '<leader>mt', tasker.CreateMarkdownTable, { desc = 'Convert to markdown' })

    -- keymaps for floating windows
    vim.keymap.set('n', '<leader>td', '<cmd>Td<cr>', { desc = 'Open Todo' })
    vim.keymap.set({ 'n', 't' }, '<leader>tt', '<cmd>Tt<cr>', { desc = 'toggle terminal' })
  end,
}
```
