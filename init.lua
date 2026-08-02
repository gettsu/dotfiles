local options = {
  title = true,
  number = true,
  shiftwidth = 4,
  tabstop = 4,
  expandtab = true,
  clipboard = "unnamedplus",
  autoindent = true,
  termguicolors = true,
  signcolumn = "yes",
  completeopt = { "menu", "menuone", "noselect" },
}

vim.opt.shortmess:append("c")
vim.opt.shada = ""
vim.opt.list = true
vim.opt.listchars:append("eol:↴")

for key, value in pairs(options) do
  vim.opt[key] = value
end

-- Use Vim's regular-expression syntax highlighting.
vim.cmd("syntax enable")

if vim.g.vscode then
  return
end

if vim.fn.has("nvim-0.11.3") == 0 then
  error("This init.lua requires Neovim 0.11.3 or newer")
end

local function paste_from_unnamed_register()
  return {
    vim.fn.getreg('"', 1, true),
    vim.fn.getregtype('"'),
  }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste_from_unnamed_register,
    ["*"] = paste_from_unnamed_register,
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { output, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local silent = { silent = true }

map({ "n", "x", "s", "o" }, "<Space>", "<Nop>", silent)
map("n", "<leader>h", "^", { silent = true, desc = "First non-blank character" })
map("n", "<leader>e", "$", { silent = true, desc = "End of line" })
map("n", "<CR><CR>", "<C-w><C-w>", { silent = true, desc = "Next window" })
map("n", "<leader>b", "<C-o>", { silent = true, desc = "Jump backward" })

require("lazy").setup({
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        highlight = { "CursorColumn", "Whitespace" },
        char = "",
      },
      whitespace = {
        highlight = { "CursorColumn", "Whitespace" },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    },
  },
  {
    "rebelot/kanagawa.nvim",
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      {
        "<leader>f",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>g",
        function()
          require("fzf-lua").git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>r",
        function()
          require("fzf-lua").grep_project()
        end,
        desc = "Grep project",
      },
      {
        "<leader>l",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "List buffers",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "tomasiser/vim-code-dark",
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local none_ls = require("null-ls")
      local sources = {}

      if vim.fn.executable("clang-format") == 1 then
        table.insert(
          sources,
          none_ls.builtins.formatting.clang_format.with({
            extra_args = {
              "--style",
              "{IndentWidth: 4, UseTab: Never, AllowShortFunctionsOnASingleLine: None}",
            },
          })
        )
      end

      if vim.fn.executable("stylua") == 1 then
        table.insert(
          sources,
          none_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          })
        )
      end

      local format_group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

      none_ls.setup({
        sources = sources,
        debug = false,
        on_attach = function(client, bufnr)
          if not client:supports_method("textDocument/formatting") then
            return
          end

          vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            buffer = bufnr,
            desc = "Format with none-ls before saving",
            callback = function()
              vim.lsp.buf.format({
                async = false,
                bufnr = bufnr,
                timeout_ms = 3000,
                filter = function(format_client)
                  return format_client.id == client.id
                end,
              })
            end,
          })
        end,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-l>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- Keep the original behavior: only explicitly enabled servers start.
        automatic_enable = false,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      local clangd_cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
      }

      vim.lsp.config("clangd", {
        cmd = clangd_cmd,
      })

      vim.lsp.config("ruff", {
        -- Let Pyright handle hover information when both Python servers attach.
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "off",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              autoImportCompletions = false,
            },
          },
        },
        -- Ruff remains the diagnostic provider for Python.
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
        },
      })

      local servers = {
        clangd = "clangd",
        rust_analyzer = "rust-analyzer",
        ruff = "ruff",
        pyright = "pyright-langserver",
      }

      for server, executable in pairs(servers) do
        if vim.fn.executable(executable) == 1 then
          vim.lsp.enable(server)
        end
      end
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    main = "scrollbar",
    opts = {},
  },
  {
    "vim-airline/vim-airline",
  },
  {
    "github/copilot.vim",
  },
  {
    "f-person/git-blame.nvim",
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {},
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
  },
})

local function format_buffer(bufnr)
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/formatting",
  })
  local preferred_client_id

  -- clangd and none-ls can both format C/C++. Prefer the explicitly configured
  -- none-ls formatter to avoid applying two formatting edits in succession.
  for _, client in ipairs(clients) do
    if client.name == "null-ls" then
      preferred_client_id = client.id
      break
    end
  end

  vim.lsp.buf.format({
    async = true,
    bufnr = bufnr,
    filter = preferred_client_id and function(client)
      return client.id == preferred_client_id
    end or nil,
  })
end

local lsp_keymap_group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_keymap_group,
  desc = "Set buffer-local LSP keymaps",
  callback = function(event)
    local function lsp_map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, {
        buffer = event.buf,
        silent = true,
        desc = desc,
      })
    end

    lsp_map("K", vim.lsp.buf.hover, "LSP hover")
    lsp_map("gf", function()
      format_buffer(event.buf)
    end, "Format buffer")
    lsp_map("gr", vim.lsp.buf.references, "LSP references")
    lsp_map("gd", vim.lsp.buf.definition, "LSP definition")
    lsp_map("gD", vim.lsp.buf.declaration, "LSP declaration")
    lsp_map("gi", vim.lsp.buf.implementation, "LSP implementation")
    lsp_map("gK", vim.diagnostic.open_float, "Line diagnostics")
  end,
})
