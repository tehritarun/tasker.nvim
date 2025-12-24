# tasker.nvim

Neovim plugin for tasklist documents

## Features

- **Titles & Subtitles**: Easily create centered titles and subtitles with decorative borders.
- **Task Management**: Quickly create task items with checkboxes `[ ]`.
- **Progress Tracking**: Mark tasks as done `[X]` or unmark them.
- **Visual Mode**: Apply changes to multiple lines at once in visual mode.

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
- `markItem`: Marks task item(s) as done `[X]`.
- `unmarkItem`: Unmarks task item(s) `[ ]`.

### Commands

- `:Td`: Opens the configured `target_file` in a floating window.

## Installation

Install the plugin with your preferred package manager. Here is an example using `lazy.nvim`:

```lua
{
  'tehritarun/tasker.nvim',
  config = function()
    local tasker = require('tasker')

    -- Optional: Configure width
    tasker.setup({ width = 60 })

    -- Keymaps
    vim.keymap.set('n', '<leader>ct', tasker.makeTitle, { desc = 'Make Title' })
    vim.keymap.set('n', '<leader>cs', tasker.makeSubTitle, { desc = 'Make Subtitle' })

    vim.keymap.set({ 'n', 'v' }, '<leader>cc', tasker.makeItem, { desc = 'Make item' })
    vim.keymap.set({ 'n', 'v' }, '<leader>cm', tasker.markItem, { desc = 'Mark item' })
    vim.keymap.set({ 'n', 'v' }, '<leader>cu', tasker.unmarkItem, { desc = 'Unmark item' })
  end,
}
```
