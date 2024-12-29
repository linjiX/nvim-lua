return {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
        {
            "[rf",
            function()
                require("flash").toggle(true)
            end,
            desc = "Enable Flash",
        },
        {
            "]rf",
            function()
                require("flash").toggle(false)
            end,
            desc = "Disable Flash",
        },
        {
            "yrf",
            function()
                require("flash").toggle()
            end,
            desc = "Toggle Flash",
        },
        {
            "<C-s>",
            function()
                require("flash").toggle()
            end,
            mode = { "c" },
            desc = "Toggle Flash",
        },
        {
            "<Leader>/",
            function()
                require("flash").jump()
            end,
            desc = "Flash Jump",
        },
        {
            "R",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Remote Flash",
        },
    },
    opts = {
        modes = {
            -- search = {
            --     enabled = true,
            -- },
            char = {
                multi_line = false,
                highlight = { backdrop = false },
            },
        },
    },
}
