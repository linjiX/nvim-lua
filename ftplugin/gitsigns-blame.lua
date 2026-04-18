local window = require("config.window")

window.set_quit_keymaps(vim.cmd.tabclose)

vim.keymap.set("n", "?", function()
    vim.cmd.popup("]GitsignsBlame")
end, {
    buffer = true,
    nowait = true,
    desc = "Open blame context menu",
})

-- make sure this keymap is set after the plugin has attached to the buffer
vim.schedule(function()
    vim.keymap.set("n", "<CR>", "s", {
        buffer = true,
        nowait = true,
        remap = true,
        desc = "Show commit in a vertical split",
    })
end)
