local utility = require("config.utility")
local window = require("config.window")
local scriptname = require("plugins.fugitive").scriptname

vim.opt_local.number = false
vim.opt_local.buflisted = false

window.set_quit_keymaps("gq", { remap = true })

vim.keymap.set("n", "<CR>", function()
    local GF = utility.get_script_function("GF", scriptname)
    local CfilePorcelain = utility.get_script_function("CfilePorcelain", scriptname)

    local target = CfilePorcelain()[1]
    if utility.is_commit_id(target) then
        vim.cmd(GF("split"))
        window.redirect_git_floatwin()
    else
        vim.cmd(GF("edit"))
    end
end, { buffer = true })
