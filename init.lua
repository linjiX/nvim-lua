vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.numberwidth = 5
vim.opt.wrap = false
vim.opt.confirm = true
vim.opt.scrolloff = 1
vim.opt.sidescrolloff = 8
vim.opt.wildmode = { "longest:full", "full" }

vim.opt.cursorline = true
vim.opt.cursorcolumn = true

vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.mouse = ""

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.list = true
vim.opt.listchars = { tab = "-->", nbsp = "+", precedes = "<", extends = ">" }

vim.opt.clipboard = "unnamedplus"

local utility = require("utility")

vim.keymap.set("n", "<C-w>m", utility.tabopen)
vim.keymap.set("n", "<C-w><C-m>", utility.tabopen)

vim.keymap.set({ "n", "x" }, "<C-p>", '"0p')

vim.keymap.set("n", "<M-l>", vim.cmd.bnext)
vim.keymap.set("n", "<M-h>", vim.cmd.bprevious)
vim.keymap.set("n", "<Leader>q", vim.cmd.bdelete)
vim.keymap.set("n", "<Leader>Q", vim.cmd.bwipeout)
vim.keymap.set("n", "<Leader>`", "<C-^>")

vim.keymap.set("n", "<BS>", vim.cmd.nohlsearch)

vim.keymap.set("c", "<C-k>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<Up>"
end, { expr = true })

vim.keymap.set("c", "<C-j>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Down>"
end, { expr = true })

vim.keymap.set("c", "<C-a>", "<HOME>")
vim.keymap.set("c", "<C-e>", "<END>")

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "grh", vim.lsp.buf.typehierarchy)
vim.keymap.set("n", "grk", vim.lsp.buf.signature_help)

local window = require("utility.window")

window.set_navigation_keymaps()

local window = require("config.window")
local augroup = vim.api.nvim_create_augroup("MyAutocmds", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        if vim.bo.buftype == "nofile" then
            window.set_quit_keymaps(nil, nil, true)
        elseif vim.bo.buftype == "help" then
            vim.cmd.wincmd("L")
            window.set_quit_keymaps(vim.cmd.helpclose)
            vim.keymap.set("n", "K", "K", { buffer = args.buf })
        elseif
            vim.bo.buftype == ""
            and not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
        then
            vim.opt_local.colorcolumn = "100"
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Restore cursor to the last position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        local exclude = { "COMMIT_EDITMSG" }

        if vim.tbl_contains(exclude, vim.fs.basename(args.file)) then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({ higroup = "TabLineSel", timeout = 300 })
    end,
})

window.setup()
require("config.buffer").setup()
require("config.diagnostic").setup()
require("config.star").setup()
require("config.jq").setup()
require("config.lazy").setup()

vim.cmd.colorscheme("tokyonight-night")
