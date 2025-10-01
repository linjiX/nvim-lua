local window = require("config.window")

vim.opt_local.buflisted = false
vim.opt_local.bufhidden = "wipe"
vim.cmd.wincmd("L")

window.set_quit_keymaps()
