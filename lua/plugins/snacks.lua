return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = false },
    },
    keys = {
        {
            "<Leader>q",
            function()
                require("snacks").bufdelete.delete()
            end,
        },
    },
}
