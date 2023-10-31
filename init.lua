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
}

vim.opt.shortmess:append("c")
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
for k, v in pairs(options) do
    vim.opt[k] = v
end

local opts = { noremap = true, silent = true }

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

require("lazy").setup(
{
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
},
{ 
    "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}
},
{
    "neoclide/coc.nvim",
    build = "yarn install --frozen-lockfile" }
)
local highlight = {
    "CursorColumn",
    "Whitespace",
}
require("ibl").setup {
    indent = { highlight = highlight, char = "" },
    whitespace = {
        highlight = highlight,
        remove_blankline_trail = false,
    },
    scope = { enabled = false },
}

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = {
      'toml',
    },
  },
}
