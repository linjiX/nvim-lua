local utility = require("config.utility")
local window = require("config.window")
local scriptname = require("plugins.fugitive").scriptname

vim.b.did_ftplugin = true
vim.fn["fugitive#BlameFileType"]()

vim.opt_local.listchars:remove({ "precedes", "extends" })
window.bind_cursorline()

window.set_quit_keymaps(vim.cmd.tabclose)

vim.keymap.set("n", "<CR>", function()
    local splitbelow = vim.o.splitbelow
    vim.opt.splitbelow = true

    local BlameCommit = utility.get_script_function("BlameCommit", scriptname)
    local ok, result = pcall(function()
        vim.cmd(BlameCommit("vsplit"))
    end)
    vim.opt.splitbelow = splitbelow

    if not ok then
        error(result)
    end
end, { buffer = true })

local function reblame(suffix)
    local win = window.tabpage_get_scrollbind_win()
    local BlameJump = utility.get_script_function("BlameJump", scriptname)

    vim.wo[win].winfixbuf = false

    vim.cmd(BlameJump(suffix))

    vim.wo[win].winfixbuf = true
    window.bind_cursorline(win)
end

for _, lhs in ipairs({ "-", "s", "u" }) do
    vim.keymap.set("n", lhs, function()
        reblame("")
    end, {
        buffer = true,
        nowait = true,
        desc = "Reblame at commit",
    })
end

vim.keymap.set("n", "P", function()
    if vim.v.count == 0 then
        vim.api.nvim_echo({ { "Use ~ (or provide a count)", "ErrorMsg" } }, true, {})
        return
    end

    reblame(("^%d"):format(vim.v.count1))
end, {
    buffer = true,
    nowait = true,
    desc = "Reblame at commit parent",
})

vim.keymap.set("n", "~", function()
    reblame(("~%d"):format(vim.v.count1))
end, {
    buffer = true,
    nowait = true,
    desc = "Reblame at commit ancestor",
})
