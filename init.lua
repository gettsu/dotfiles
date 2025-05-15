local options = {
  title = true,
  number = true,
  shiftwidth = 4,
  tabstop = 4,
  expandtab = true,
  clipboard = "unnamedplus",
  autoindent = true,
  termguicolors = true,
}

vim.opt.shortmess:append("c")
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
for k, v in pairs(options) do
  vim.opt[k] = v
end

local opts = { noremap = true, silent = true }

if not vim.g.vscode then
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }

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

  --local keymap = vim.keymap
  local keymap = vim.api.nvim_set_keymap

  --Remap space as leader key
  keymap("", "<Space>", "<Nop>", opts)
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Modes
  keymap("n", "<Space>h", "^", opts)
  keymap("n", "<Space>l", "$", opts)
  -- 窓の切り替え --
  keymap("n", "<CR><CR>", "<C-w><C-w>", opts)

  require("lazy").setup({
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {},
    },
    {
      "rebelot/kanagawa.nvim",
    },
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
      "williamboman/mason.nvim",
      version = "^1.0.0",
    },
    {
      "williamboman/mason-lspconfig.nvim",
      version = "^1.0.0",
    },
    {
      "tomasiser/vim-code-dark",
    },
    {
      "nvimtools/none-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
      "nvim-treesitter/nvim-treesitter",
    },
    {
      "neovim/nvim-lspconfig",
    },
    { "hrsh7th/nvim-cmp" }, -- Required
    { "hrsh7th/cmp-nvim-lsp" }, -- Required
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
      "airblade/vim-gitgutter",
    },
  })

  keymap("n", "<leader>f", ":lua require('fzf-lua').files()<CR>", { silent = true })
  keymap("n", "<leader>g", ":lua require('fzf-lua').git_status()<CR>", { silent = true })
  keymap("n", "<leader>r", ":lua require('fzf-lua').grep_project()<CR>", { silent = true })

  keymap("n", "<leader>b", "<C-o>", { silent = true })

  local cmp = require("cmp")
  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-l>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
  })
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local lspconfig = require("lspconfig")
  if vim.fn.executable("clangd-17") == 1 then
    lspconfig.clangd.setup({
      capabilities = capabilities,
      cmd = { "clangd-17", "--background-index", "--clang-tidy" },
    })
  end
  if vim.fn.executable("ruff") == 1 then
    lspconfig.ruff.setup({})
  end
  if vim.fn.executable("pyright") == 1 then
    require("lspconfig").pyright.setup({
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "off",
            autoImportCompletions = false,
          },
          linting = {
            enabled = false,
          },
        },
      },
      -- Disable all diagnostics from Pyright
      handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
      },
    })
  end
  vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  vim.keymap.set("n", "gK", "<cmd>lua vim.diagnostic.open_float()<CR>")
  vim.cmd("colorscheme kanagawa")

  local highlight = {
    "CursorColumn",
    "Whitespace",
  }
  require("ibl").setup({
    indent = { highlight = highlight, char = "" },
    whitespace = {
      highlight = highlight,
      remove_blankline_trail = false,
    },
    scope = { enabled = false },
  })
  require("mason").setup()
  require("mason-lspconfig").setup()
  require("mason-lspconfig").setup_handlers({
    function(server_name) -- default handler (optional)
      require("lspconfig")[server_name].setup({
        on_attach = on_attach, --keyバインドなどの設定を登録
        capabilities = capabilities, --cmpを連携
      })
    end,
  })

  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  local none_ls = require("null-ls")
  none_ls.setup({
    sources = {
      none_ls.builtins.formatting.black,
      none_ls.builtins.formatting.clang_format,
      none_ls.builtins.formatting.stylua.with({
        extra_args = { "--indent-type", "Spaces", "--indent-width", 2 },
      }),
    },
    debug = false,
    on_attach = function(client, bufnr)
      if client:supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    end,
  })
end
