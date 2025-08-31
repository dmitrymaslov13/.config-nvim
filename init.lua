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

  -- Telescope file browser
  { 
    "nvim-telescope/telescope-file-browser.nvim", 
    dependencies = { "nvim-telescope/telescope.nvim" } 
  },
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
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope file_browser<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'n',
  '<leader>fp',
  ":Telescope file_browser path=%:p:h<CR>",
  { noremap = true, silent = true }
)

-- Кеймап: открыть file browser относительно корня проекта (git root)
vim.api.nvim_set_keymap(
  'n',
  '<leader>fg',
  ":Telescope file_browser path=%:p:h cwd=$(git rev-parse --show-toplevel)<CR>",
  { noremap = true, silent = true }
)

-- Кеймап: открыть file browser относительно открытой директории в vim
vim.api.nvim_set_keymap(
  'n',
  '<leader>fr',
  ":Telescope file_browser path=%:p:h cwd=vim.loop.cwd()<CR>",
  { noremap = true, silent = true }
)
