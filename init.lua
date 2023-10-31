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

require("lazy").setup({
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
    branch = "release"
},
{
    "rebelot/kanagawa.nvim",
},
{
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
},
})

keymap("n", "<leader>f", ":lua require('fzf-lua').files()<CR>", {  silent = true })
keymap("n", "<leader>g", ":lua require('fzf-lua').git_status()<CR>", {  silent = true })
keymap("n", "<leader>r", ":lua require('fzf-lua').grep_project()<CR>", {  silent = true })

local coc_opts = {
	silent = true,
	noremap = true,
	expr = true,
}

-- GoTo code navigation
keymap("n", "gd", "<Plug>(coc-definition)", {silent = true})
keymap("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keymap("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keymap("n", "gr", "<Plug>(coc-references)", {silent = true})

keymap("n", "<leader>b", "<C-o>", {  silent = true })

vim.keymap.set("i", "<Tab>",
function()
    is_visible = vim.fn["coc#pum#visible"]()
    if is_visible == 1 then
        return vim.fn["coc#pum#confirm"]()
    else
        return "<Tab>"
    end
end, coc_opts)

function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
keymap("n", "K", ':lua _G.show_docs()<CR>', {silent = true})


vim.cmd "colorscheme kanagawa"

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
