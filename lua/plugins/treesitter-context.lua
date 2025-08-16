local context = require("utility").lazy_require("treesitter-context")

return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    keys = {
        {
            "[rc",
            context.enable(),
            desc = "Enable Treesiter Context",
        },
        {
            "]rc",
            context.disable(),
            desc = "Disable Treesiter Context",
        },
        {
            "yrc",
            context.toggle(),
            desc = "Toggle Treesiter Context",
        },
        {
            "[c",
            context.go_to_context(vim.v.count1),
            mode = { "n", "x" },
            desc = "Previous Treesiter Context",
        },
        {
            "[C",
            context.go_to_context(-1),
            mode = { "n", "x" },
            desc = "Top Treesiter Context",
        },
    },
    opts = {
        max_lines = 10,
        multiline_threshold = 1,
        trim_scope = "inner",
    },
}
