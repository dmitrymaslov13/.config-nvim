local bootstrapModule = require("bootstrap")

bootstrapModule.bootstrap()

-- плагины
require("lazy").setup({
    -- Telescope для поиска файлов
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Telescope для поиска файлов
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    -- Сессии
    {
        "rmagatti/auto-session",
        config = function()
            -- Обязательно включаем локальные опции сессий
            vim.o.sessionoptions = "buffers,curdir,tabpages,winpos,winsize,localoptions"

            require("auto-session").setup {
              log_level = "info",
              auto_session_enable_last_session = false,  -- восстанавливать последнюю сессию
              auto_session_root_dir = vim.fn.stdpath("data").."/sessions/",
              session_lens_enable = true,
            }

            -- Подключение сессии если была в текущей директории
            vim.api.nvim_create_autocmd("VimEnter", {
              callback = function()
                local cwd = vim.fn.getcwd()
                local session_name = vim.fn.fnamemodify(cwd, ":p:h:t") -- имя сессии по имени папки
                local session_path = vim.fn.stdpath("data").."/sessions/"..session_name..".vim"

                if vim.fn.filereadable(session_path) == 1 then
                  vim.cmd("silent! source " .. session_path)
                end
              end
            })

        end
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
          sources = { "filesystem", "git_status", "buffers" }, -- три режима
          source_selector = {
            winbar = true, -- отображать переключатель сверху панели
            show_scrolled_off_parent = false,
            separator = " | ", -- разделитель между кнопками
            content_layout = "center",
            tabs_layout = "equal", -- равномерные вкладки
          },
          window = {
            position = "left", -- 👈 открываем дерево по центру экрана
            width = 50,
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
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("bufferline").setup({
          options = {
            diagnostics = "nvim_lsp",       -- показывать ошибки от LSP
            separator_style = "slant",      -- стиль разделителей: "slant", "thick", "thin"
            show_buffer_close_icons = false,
            show_close_icon = true,
            always_show_bufferline = true,
          },
        })
        end
    },

    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "neovim/nvim-lspconfig" },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = {
              "ts_ls",
              "lua_ls",
              "angularls",
              "dockerls", -- Dockerfile
              "docker_compose_language_service", -- docker-compose.yaml
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
          vim.keymap.set("n", "[d", bufnr.goto_prev, opts)
          vim.keymap.set("n", "]d", bufnr.goto_next, opts)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        end

        lspconfig.lua_ls.setup({
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" }, -- говорим, что vim глобален
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true), -- Neovim runtime
                checkThirdParty = false,
              },
            },
          },
        })

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
      "folke/which-key.nvim",
      event = "VeryLazy", -- чтобы не грузился сразу
      config = function()
        require("which-key").setup({
            plugins = {
                presets = {
                    operators = true, -- d, y, etc.
                    motions   = true, -- w, e, etc.
                    text_objects = true, -- aw, iw, etc.
                    windows = true, -- <c-w>
                    nav = true, -- gj, gk, etc.
                    z = true, -- folds
                    g = true, -- git & motions
                },
            }
        })
      end,
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
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true

vim.cmd.colorscheme "catppuccin-macchiato"


-- Telescope
vim.keymap.set("n", "<leader>ff", "<Cmd>Telescope find_files<CR>", { desc = "Найти файл" })
vim.keymap.set("n", "<leader>fg", "<Cmd>Telescope live_grep<CR>", { desc = "Найти файл содержащий строку" })
vim.keymap.set("n", "<leader>bl", "<Cmd>Telescope buffers<CR>", { desc = "Список буферов" })


-- Дерево файлов
vim.keymap.set("n", "<leader>e", function()
  require("neo-tree.command").execute({ toggle = true })
end, { desc = "Toggle Neo-tree" })
-- vim.keymap.set("n", "<leader>e", "<Cmd>Neotree reveal toggle<CR>", { desc = "Дерево файлов" })
-- vim.keymap.set("n", "<leader>e", "<Cmd>Neotree reveal toggle<CR>", { desc = "Дерево файлов" })
-- мапы внутри дерева (в normal mode)
-- a → создать файл/папку
-- d → удалить
-- r → переименовать
-- <CR> → открыть файл в текущем окне

-- Сброс поиска
vim.keymap.set("n", "<leader>h", "<Cmd>nohl<CR>", { desc = "Сброс подсветки поиска" })

-- Буферы
vim.keymap.set("n", "<leader>bn", "<Cmd>BufferLineCycleNext<CR>", { desc = "Следующий буфер" })
vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Предыдущий буфер" })
vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Закрыть буфер" })

-- Visual mode: сдвиг блока и сохранение выделения
vim.keymap.set("v", "<", "<gv", { desc = "Сдвинуть влево и остаться в VISUAL" })
vim.keymap.set("v", ">", ">gv", { desc = "Сдвинуть вправо и остаться в VISUAL" })

-- Visual block mode (Ctrl+v) — тоже сохраняем выделение
vim.keymap.set("x", "<", "<gv", { desc = "Сдвинуть блок влево и остаться в VISUAL" })
vim.keymap.set("x", ">", ">gv", { desc = "Сдвинуть блок вправо и остаться в VISUAL" })
