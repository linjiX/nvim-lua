return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        {
            "<Leader>td",
            ":Trouble diagnostics toggle filter.buf=0<CR>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<Leader>tD",
            ":Trouble diagnostics toggle<CR>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<Leader>tl",
            ":Trouble loclist toggle<CR>",
            desc = "Location List (Trouble)",
        },
        {
            "<Leader>tq",
            ":Trouble qflist toggle<CR>",
            desc = "Quickfix List (Trouble)",
        },
    },
    opts = {},
}
