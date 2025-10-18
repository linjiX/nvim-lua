return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
        {
            "<Leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
    opts = {
        preset = "modern",
        delay = 800,
    },
}
