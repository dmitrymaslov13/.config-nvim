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
    },
    -- LSP + Mason + Autocomplete
    {
      "williamboman/mason.nvim",
      config = true
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "neovim/nvim-lspconfig" },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { 
              "ts_ls", 
              "angularls",
              "dockerls",                     -- Dockerfile
              "docker_compose_language_service", -- docker-compose.yml
          },
        })

        local lspconfig = require("lspconfig")

        -- Общие keymaps для LSP
        local on_attach = function(_, bufnr)
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Девинишены
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

          -- Инфа
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

          -- Экшены
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          
          -- Диагностика
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        end

        -- Настройка TypeScript/JavaScript (tsserver)
        lspconfig.ts_ls.setup({
          on_attach = on_attach,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })

        -- Настройка Angular
        lspconfig.angularls.setup({
          on_attach = on_attach,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })
      end
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip"
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          mapping = {
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
          },
          sources = {
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "path" },
          },
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
        })
      end
    }

})

require("telescope").setup({
  pickers = {
    buffers = {
      sort_mru = true,      -- сортировать по последнему использованию
      mappings = {
--        i = {
--         ["<C-D>"] = "delete_buffer", -- удалить буфер в insert mode
--      },
        n = {
          ["D"] = "delete_buffer",     -- удалить буфер в normal mode
        },
      },
    },
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
vim.api.nvim_set_keymap("n", "<leader>bb", ":Telescope buffers<CR>", { noremap = true, silent = true })

-- Дерево файлов
vim.api.nvim_set_keymap('n', '<leader>e', ':Neotree reveal toggle<CR>', { silent = true })
-- мапы внутри дерева (в normal mode)
-- a → создать файл/папку
-- d → удалить
-- r → переименовать
-- <CR> → открыть файл в текущем окне

-- Сброс поиска
vim.api.nvim_set_keymap('n', '<leader>h', ':nohl<CR>', { silent = true })
