-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- плагины
require("lazy").setup({
      -- Telescope для поиска файлов
    { 
        "nvim-telescope/telescope.nvim", 
        dependencies = { "nvim-lua/plenary.nvim" } 
    },
    
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- иконки
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          window = {
            position = "float", -- 👈 открываем дерево по центру экрана
            width = 50,
            height = 20,
          },
          follow_current_file = {
              enabled = true,   -- 👈 следим за текущим файлом
              leave_dirs_open = false, -- закрывать несвязанные папки
          },
          filesystem = {
            filtered_items = { 
                hide_dotfiles = false, -- показывать скрытые файлы
                hide_gitignored = true,
            },
          },
        })

      end
    }
})

-- пробел как leader
vim.g.mapleader = " "

-- базовые настройки
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4 
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- Telescope keymap
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- Дерево файлов
vim.api.nvim_set_keymap('n', '<leader>e', ':Neotree reveal toggle<CR>', { silent = true })
-- мапы внутри дерева (в normal mode)
-- a → создать файл/папку
-- d → удалить
-- r → переименовать
-- <CR> → открыть файл в текущем окне

-- Сброс поиска
vim.api.nvim_set_keymap('n', '<leader>h', ':nohl<CR>', { silent = true })
