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

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

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
vim.keymap.set("n", "grt", vim.lsp.buf.type_definition)
vim.keymap.set("n", "grh", vim.lsp.buf.typehierarchy)
vim.keymap.set("n", "grk", vim.lsp.buf.signature_help)
vim.keymap.set("n", "gro", vim.lsp.buf.document_symbol)
vim.keymap.set("n", "grO", vim.lsp.buf.workspace_symbol)

local window = require("utility.window")

for _, cmd in ipairs({ "q", "wq" }) do
    vim.keymap.set("ca", cmd, function()
        return window.smart_quit(cmd)
    end, { expr = true })
end

local star = require("utility.star")

for _, key in ipairs({ "*", "g*", "#", "g#" }) do
    vim.keymap.set("n", key, function()
        star.star(key)
    end)
end

for _, key in ipairs({ "*", "#" }) do
    vim.keymap.set("x", key, function()
        star.visual_star(key)
    end)
end

local buffer = require("utility.buffer")

vim.keymap.set("n", "<Leader>u", buffer.reopen_buffer)

vim.api.nvim_create_autocmd("BufUnload", {
    group = vim.api.nvim_create_augroup("MyBufUnload", { clear = true }),
    pattern = "*",
    callback = buffer.add_unloaded_buffer,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("MyAutocmd", { clear = true }),
    pattern = "*",
    callback = function(args)
        if vim.bo.buftype == "nofile" then
            window.set_quit_keymaps()
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
    group = vim.api.nvim_create_augroup("MyFiletype", { clear = true }),
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Restore cursor to the last position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("MyCursor", { clear = true }),
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

-- Diagnostic
vim.keymap.set("n", "<Leader>K", vim.diagnostic.open_float)

vim.diagnostic.config({
    float = {
        border = "rounded",
        source = true,
    },
    virtual_text = {
        prefix = "●",
        source = true,
    },
})

require("config.lazy")

vim.cmd.colorscheme("tokyonight-night")
