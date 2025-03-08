return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        {
            "<Leader>td",
            ":Trouble diagnostics toggle filter.buf=0<CR>",
            silent = true,
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<Leader>tD",
            ":Trouble diagnostics toggle win.relative=editor<CR>",
            silent = true,
            desc = "Diagnostics (Trouble)",
        },
        {
            "<Leader>tl",
            ":Trouble loclist toggle<CR>",
            silent = true,
            desc = "Location List (Trouble)",
        },
        {
            "<Leader>tq",
            ":Trouble qflist toggle<CR>",
            silent = true,
            desc = "Quickfix List (Trouble)",
        },
    },
    opts = {
        focus = true,
        win = { relative = "win" },
        keys = {
            ["<C-s>"] = nil,
            ["<C-x>"] = "jump_split",
        },
    },
}
