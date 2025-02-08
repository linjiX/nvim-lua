return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        {
            "<Leader>q",
            function()
                require("snacks").bufdelete.delete()
            end,
        },
    },
    opts = function()
        vim.opt.shortmess:append("I")

        return {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = false },
            indent = { enabled = true },
        }
    end,
}
