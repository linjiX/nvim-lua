local utility = require("utility")
local window = require("config.window")
local scriptname = require("plugins.fugitive").scriptname

vim.b.did_ftplugin = true
vim.fn["fugitive#BlameFileType"]()

vim.opt_local.listchars:remove({ "precedes", "extends" })

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
