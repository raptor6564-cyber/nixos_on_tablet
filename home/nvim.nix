{ config, lib, pkgs, ... }: {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;

      # Устанавливаем treesitter и нужные грамматики через Nix
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (p: [ p.lua p.bash p.nix p.json p.markdown ]))
        # Или используйте (nvim-treesitter.withAllGrammars) для установки всех доступных языков
      ];

      extraLuaConfig = ''
        vim.opt.ignorecase = true
        vim.opt.number = true
        vim.opt.scrolloff = 8
        vim.opt.keymap = 'russian-jcukenwin'
        vim.opt.iminsert = 0
        vim.opt.wrapscan = false
        vim.opt.foldcolumn = '1'
        vim.opt.foldenable = true
        vim.opt.foldmethod = 'manual'
        vim.cmd.colorscheme 'habamax'
        vim.opt.regexpengine = 2
        vim.opt.clipboard = 'unnamedplus'

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "nix",
          callback = function()
            vim.bo.shiftwidth = 2  -- 2 пробела для отступа
            vim.bo.tabstop = 2     -- 2 пробела для табуляции
            vim.bo.softtabstop = 2 -- 2 пробела при нажатии Tab
            vim.bo.expandtab = true  -- преобразовывать табы в пробелы
          end
        });

        -- Устанавливаем лидер-клавишу
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        -- Автоматическая установка lazy.nvim
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git", "clone", "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        -- 2. Включаем treesitter (через нативный API Neovim 0.12)
        vim.api.nvim_create_autocmd('FileType', {
          pattern = { "lua", "bash", "nix", "json", "markdown" },
          callback = function()
            pcall(vim.treesitter.start)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })

        require("lazy").setup({

        -- 1. Цветовая тема (по желанию)
        {
          "folke/tokyonight.nvim",
          lazy = false,
          priority = 1000,
          config = function()
            vim.cmd.colorscheme("tokyonight-night")
          end,
        },


        -- 3. LSP (новый синтаксис для Neovim 0.11+)
        {
          "neovim/nvim-lspconfig",
          dependencies = { "hrsh7th/cmp-nvim-lsp" },
          config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Настраиваем Lua LSP через нативный API Neovim 0.11
            vim.lsp.config('lua_ls', {
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = {
                    globals = { "vim" },
                  },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              },
            })

            -- Включаем LSP сервер
            vim.lsp.enable('lua_ls')

            -- Горячие клавиши LSP (остаются прежними)
            vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("UserLspConfig", {}),
              callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              end,
            })
          end,
        },

        -- 4. Автодополнение (nvim-cmp)
        {
          "hrsh7th/nvim-cmp",
          dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
          },
          config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"]     = cmp.mapping.abort(),
                ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                ["<Tab>"]     = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { "i", "s" }),
                ["<S-Tab>"]   = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
              }, {
                { name = "buffer" },
                { name = "path" },
              }),
            })
          end,
        },

        -- 5. Форматирование (conform.nvim вызывает stylua из Nix)
        {
          "stevearc/conform.nvim",
          config = function()
            require("conform").setup({
              formatters_by_ft = {
                lua = { "stylua" },
              },
              format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
              },
            })
          end,
        },

        -- 6. Навигация: файловый менеджер и поиск
        {
          "nvim-tree/nvim-tree.lua",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
          end,
        },
        {
          "nvim-telescope/telescope.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
          config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
          end,
        },

        -- 7. Статус-бар (по желанию)
        {
          "nvim-lualine/lualine.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          config = function()
            require("lualine").setup()
          end,
        },
      })

      -- Базовые настройки редактора
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
      vim.opt.termguicolors = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.undofile = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true

      -- Запустить текущий файл через LuaJIT в вертикальном сплит-терминале
      vim.keymap.set("n", "<leader>lr", function()
        local file = vim.fn.expand("%")
        vim.cmd("vsplit | terminal luajit " .. file)
      end, { desc = "Run current file with LuaJIT" })

      -- Запустить текущую строку в терминале
      vim.keymap.set("n", "<leader>ll", function()
        local line = vim.fn.getline(".")
        vim.cmd("botright terminal luajit -e '" .. line .. "'")
      end, { desc = "Run current line with LuaJIT" })
      '';

      # Системные зависимости для Neovim и Lua-разработки
      extraPackages = with pkgs; [
        # --- Языковые инструменты Lua ---
        lua-language-server   # LSP (подсказки, переход к определению)
        stylua                # Форматирование кода
        lua51Packages.luacheck              # Статический анализ (линтер)

        # --- Зависимости для Treesitter ---
        gcc                   # Нужен для компиляции парсеров Treesitter

        # --- Вспомогательные утилиты ---
        ripgrep               # Поиск по файлам (зависимость Telescope)
        fd                    # Быстрый поиск файлов (зависимость Telescope)
        git                   # Нужен для скачивания плагинов

        luajit # Интерпретатор Lua
      ];
    };
  };
}
