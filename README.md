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
    width = 50 -- Width for titles and subtitles (default: 50)
})
```

## Usage

The plugin exposes the following functions which can be mapped to keys:

- `makeTitle`: Converts the current line into a centered title.
- `makeSubTitle`: Converts the current line into a centered subtitle.
- `makeItem(mode)`: Converts line(s) into task items. `mode` can be `'n'` (normal) or `'v'` (visual).
- `markItem(mode)`: Marks task item(s) as done `[X]`.
- `unmarkItem(mode)`: Unmarks task item(s) `[ ]`.

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

    vim.keymap.set('n', '<leader>cc', function() tasker.makeItem('n') end, { desc = 'Make item' })
    vim.keymap.set('v', '<leader>cc', function() tasker.makeItem('v') end, { desc = 'Make item' })

    vim.keymap.set('n', '<leader>cm', function() tasker.markItem('n') end, { desc = 'Mark item' })
    vim.keymap.set('v', '<leader>cm', function() tasker.markItem('v') end, { desc = 'Mark item' })

    vim.keymap.set('n', '<leader>cu', function() tasker.unmarkItem('n') end, { desc = 'Unmark item' })
    vim.keymap.set('v', '<leader>cu', function() tasker.unmarkItem('v') end, { desc = 'Unmark item' })
  end,
}
```
