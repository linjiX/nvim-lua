return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = function()
        local snacks = require("snacks")
        return {
            {
                "<Leader>q",
                snacks.bufdelete.delete,
            },
            {
                "[rw",
                snacks.words.enable,
            },
            {
                "]rw",
                snacks.words.disable,
            },
            {
                "yrw",
                function()
                    if snacks.words.is_enabled() then
                        snacks.words.disable()
                    else
                        snacks.words.enable()
                    end
                end,
            },
        }
    end,
    opts = function()
        vim.opt.shortmess:append("I")

        return {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
            indent = { enabled = true },
        }
    end,
}
