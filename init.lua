vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.wrap = false
vim.opt.confirm = true
vim.opt.scrolloff = 1

vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.colorcolumn = "100"

vim.opt.splitright = true
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

vim.keymap.set({ "n", "x" }, "<C-p>", '"0p')

vim.keymap.set("n", "<M-]>", ":bnext<CR>")
vim.keymap.set("n", "<M-[>", ":bprevious<CR>")
vim.keymap.set("n", "<Leader>q", ":bwipeout<CR>")
vim.keymap.set("n", "<Leader>`", "<C-^>")

vim.keymap.set("n", "<BS>", ":nohlsearch<CR>", { silent = true })

vim.keymap.set("c", "<C-k>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<Up>"
end, { expr = true })

vim.keymap.set("c", "<C-j>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Down>"
end, { expr = true })

vim.keymap.set("c", "<C-a>", "<HOME>")
vim.keymap.set("c", "<C-e>", "<END>")

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<Leader>jj", vim.lsp.buf.definition)
vim.keymap.set("n", "<Leader>jr", vim.lsp.buf.references)
vim.keymap.set("n", "<Leader>ji", vim.lsp.buf.implementation)
vim.keymap.set("n", "<Leader>jt", vim.lsp.buf.type_definition)
vim.keymap.set("n", "<Leader>jh", vim.lsp.buf.typehierarchy)
vim.keymap.set("n", "<Leader>jk", vim.lsp.buf.signature_help)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<Leader>lr", vim.lsp.buf.rename)

vim.keymap.set("n", "[oj", ":LspStart<CR>")
vim.keymap.set("n", "]oj", ":LspStop<CR>")
vim.keymap.set("n", "yoJ", ":LspRestart<CR>")

local function get_buflisted_wins()
    local wins = {}
    local current_win = vim.api.nvim_get_current_win()

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win ~= current_win then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buflisted then
                table.insert(wins, win)
            end
        end
    end
    return wins
end

local function smart_quit(write)
    local cmd = write and "wq" or "q"

    if vim.fn.getcmdtype() ~= ":" or vim.fn.getcmdline() ~= cmd or #get_buflisted_wins() ~= 0 then
        return cmd
    end

    cmd = #vim.api.nvim_list_tabpages() > 1 and "tabclose" or "qa"

    return write and "w | " .. cmd or cmd
end

local function smart_q()
    return smart_quit(false)
end

local function smart_wq()
    return smart_quit(true)
end

vim.keymap.set("ca", "q", smart_q, { silent = false, expr = true })
vim.keymap.set("ca", "wq", smart_wq, { silent = false, expr = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("MyAutocmd", { clear = true }),
    pattern = "*",
    callback = function(args)
        if vim.bo.buftype == "nofile" then
            vim.keymap.set("n", "q", ":q<CR>", { buffer = args.buf, silent = true })
            vim.keymap.set("n", "<Leader>q", ":q<CR>", { buffer = args.buf, silent = true })
        elseif vim.bo.buftype == "help" then
            vim.cmd("wincmd L")
            vim.keymap.set("n", "q", ":helpclose<CR>", { buffer = args.buf, silent = true })
            vim.keymap.set("n", "<Leader>q", ":helpclose<CR>", { buffer = args.buf, silent = true })
        end
    end,
})

local MyFiletype = vim.api.nvim_create_augroup("MyFiletype", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = MyFiletype,
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = MyFiletype,
    pattern = "help",
    callback = function()
        vim.keymap.set("n", "K", "K", { buffer = true, remap = false })
    end,
})

-- Restore cursor to the last position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("MyCursor", { clear = true }),
    pattern = "*",
    callback = function(args)
        local exclude = { "gitcommit" }
        local buf = args.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].cursor_restored then
            return
        end
        vim.b[buf].cursor_restored = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local line_count = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

require("config.lazy")

vim.cmd.colorscheme("tokyonight-night")
