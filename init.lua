--- Options ---
local options = {
    title = true,
    clipboard = "unnamedplus",
    number = true,
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
    autoindent = true,
    termguicolors = true,
    mouse = "",
}

vim.opt.shortmess:append("c")
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
for k, v in pairs(options) do
    vim.opt[k] = v
end

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

keymap("n", "<Space>h", "^", opts)
keymap("n", "<Space>l", "$", opts)

-- 窓の切り替え --
keymap("n", "<CR><CR>", "<C-w><C-w>", opts)

vim.cmd[[packadd packer.nvim]]
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]
require'packer'.startup(function()
    use 'wbthomason/packer.nvim'
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    use'lukas-reineke/indent-blankline.nvim'
    use'nvim-lua/plenary.nvim'
    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.0',
      requires = { {'nvim-lua/plenary.nvim'} }
    }
    use'mhartington/oceanic-next'
    use'airblade/vim-gitgutter'
    use'neovim/nvim-lspconfig'
    use'williamboman/mason.nvim'
    use'williamboman/mason-lspconfig.nvim'
    use'hrsh7th/cmp-nvim-lsp'
    use'hrsh7th/cmp-buffer'
    use'hrsh7th/cmp-path'
    use'hrsh7th/cmp-cmdline'
    use'hrsh7th/nvim-cmp'
    use'vim-airline/vim-airline'
    use'vim-airline/vim-airline-themes'
    use'jose-elias-alvarez/null-ls.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use'simeji/winresizer'
end)

require('indent_blankline').setup {
    show_end_of_line = true,
}
vim.cmd 'colorscheme OceanicNext'

require('telescope').setup({
 defaults = {
    layout_config = {
          vertical = { width = 0.5 }
    },
  },
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>r', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {})

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    -- Show diagnostics in a floating window
  vim.keymap.set('n', 'gk', vim.diagnostic.open_float, b, bufopts)
  -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
require("mason-lspconfig").setup()

local nvim_lsp = require('lspconfig')
nvim_lsp["gopls"].setup{
    on_attach = on_attach,
}
nvim_lsp["rust_analyzer"].setup{
    on_attach = on_attach,
}
nvim_lsp["dockerls"].setup{
    on_attach = on_attach,
}
nvim_lsp["clangd"].setup{
    on_attach = on_attach,
}
nvim_lsp["texlab"].setup{
    on_attach = on_attach,
}
nvim_lsp["tsserver"].setup{
    on_attach = on_attach,
}
nvim_lsp["sumneko_lua"].setup{
    on_attach = on_attach,
}
nvim_lsp["eslint"].setup{
    on_attach = on_attach,
}
nvim_lsp["zls"].setup{
    on_attach = on_attach,
}

local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local sources = {
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.rustfmt,
}
null_ls.setup({
    on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end
        end,
    sources = sources,
})

local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    -- { name = "buffer" },
    -- { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = {
      'toml',
    },
  },
}
