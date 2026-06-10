local utility = require("config.utility")
local window = require("config.window")
local get_script_function = require("plugins.fugitive").get_script_function

vim.opt_local.number = false
vim.opt_local.buflisted = false
vim.opt_local.winfixbuf = true

window.set_quit_keymaps("gq", { remap = true })

vim.keymap.set("n", "<CR>", function()
    local GF = get_script_function("GF")
    local CfilePorcelain = get_script_function("CfilePorcelain")

    local target = CfilePorcelain()[1]
    if utility.is_commit_id(target) then
        vim.cmd(GF("split"))
        window.redirect_git_floatwin()
    else
        vim.cmd(GF("edit"))
    end
end, { buffer = true })
