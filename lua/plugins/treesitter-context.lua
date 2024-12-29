return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    keys = {
        {
            "[rc",
            function()
                require("treesitter-context").enable()
            end,
            desc = "Enable Treesiter Context",
        },
        {
            "]rc",
            function()
                require("treesitter-context").disable()
            end,
            desc = "Disable Treesiter Context",
        },
        {
            "yrc",
            function()
                require("treesitter-context").toggle()
            end,
            desc = "Toggle Treesiter Context",
        },
        {
            "[c",
            function()
                require("treesitter-context").go_to_context(vim.v.count1)
            end,
            mode = { "n", "x" },
            desc = "Previous Treesiter Context",
        },
        {
            "[C",
            function()
                require("treesitter-context").go_to_context(-1)
            end,
            mode = { "n", "x" },
            desc = "Top Treesiter Context",
        },
    },
    opts = {
        max_lines = 10,
        trim_scope = "inner",
    },
}
