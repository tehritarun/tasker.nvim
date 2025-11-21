# tasker.nvim

Neovim plugin for tasklist documents

## Installation

Install plugin with `Lazy`

``` lua
{
  'tehritarun/tasker.nvim',
  config = function()
    vim.keymap.set('n', '<leader>ct', require('tasker').makeTitle, { desc = 'Make Title' })
    vim.keymap.set('n', '<leader>cs', require('tasker').makeSubTitle, { desc = 'Make Subtitle' })

    vim.keymap.set('n', '<leader>cc', function()
      require('tasker').makeItem 'n'
    end, { desc = 'Make item' })

    vim.keymap.set('v', '<leader>cc', function()
      require('tasker').makeItem 'v'
    end, { desc = 'Make item' })

    vim.keymap.set('n', '<leader>cm', function()
      require('tasker').markItem 'n'
    end, { desc = 'Mark item' })

    vim.keymap.set('v', '<leader>cm', function()
      require('tasker').markItem 'v'
    end, { desc = 'Mark item' })

    vim.keymap.set('n', '<leader>cu', function()
      require('tasker').unmarkItem 'n'
    end, { desc = 'Mark item' })

    vim.keymap.set('v', '<leader>cu', function()
      require('tasker').unmarkItem 'v'
    end, { desc = 'Mark item' })
  end,
}
```
