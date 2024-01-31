print("You are Welcome!")

-- INSTALL PLUGIN MANAGER
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- INSTALL PLUGINS
require("lazy").setup({
  "nvim-treesitter/nvim-treesitter",
  "neovim/nvim-lspconfig",
})

-- START LSPs
local lspconfig = require 'lspconfig'
local lsp_servers = {
	'tsserver',
	'angularls',
	'html',
}

for i, lsp_server in ipairs(lsp_servers) do
	lspconfig[lsp_server].setup({})
end

-- SET SPACE TO LEADERMAP
vim.g.mapleader = "<Space>"

-- SET TABSIZE
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true

