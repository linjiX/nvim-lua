local trouble = require("config.utility").lazy_require("trouble")

return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        {
            "<Leader>td",
            trouble.toggle({ mode = "diagnostics", filter = { buf = 0 } }),
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<Leader>tD",
            trouble.toggle({ mode = "diagnostics", win = { relative = "editor" } }),
            desc = "Diagnostics (Trouble)",
        },
        {
            "<Leader>tl",
            trouble.toggle({ mode = "loclist" }),
            desc = "Location List (Trouble)",
        },
        {
            "<Leader>tq",
            trouble.toggle({ mode = "qflist" }),
            desc = "Quickfix List (Trouble)",
        },
    },
    opts = {
        open_no_results = false,
        focus = true,
        win = { relative = "win" },
        keys = {
            ["<C-s>"] = nil,
            ["<C-x>"] = "jump_split",
        },
    },
}
