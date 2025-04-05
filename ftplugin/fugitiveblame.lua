local window = require("utility.window")

vim.opt_local.listchars:remove({ "precedes", "extends" })

window.set_quit_keymaps("gq", { remap = true })
