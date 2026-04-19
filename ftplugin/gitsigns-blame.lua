local blame_line_in_blame = require("plugins.gitsign").blame_line_in_blame
local window = require("config.window")

vim.opt_local.cursorbind = true

window.set_quit_keymaps(vim.cmd.tabclose)

vim.keymap.set("n", "?", function()
    vim.cmd.popup("]GitsignsBlame")
end, {
    buffer = true,
    nowait = true,
    desc = "Open blame context menu",
})

for _, lhs in ipairs({ "K", "<Leader>gm" }) do
    vim.keymap.set("n", lhs, blame_line_in_blame, {
        buffer = true,
        nowait = true,
        desc = "Blame line",
    })
end

-- make sure this keymap is set after the plugin has attached to the buffer
vim.schedule(function()
    vim.keymap.set("n", "<CR>", "s", {
        buffer = true,
        nowait = true,
        remap = true,
        desc = "Show commit in a vertical split",
    })
end)
