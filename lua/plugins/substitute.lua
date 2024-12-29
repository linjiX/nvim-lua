return {
    "gbprod/substitute.nvim",
    keys = {
        {
            "s",
            function()
                require("substitute").operator()
            end,
        },
        {
            "ss",
            function()
                require("substitute").line()
            end,
        },
        {
            "S",
            function()
                require("substitute").eol()
            end,
        },
        {
            "s",
            function()
                require("substitute").visual()
            end,
            mode = "x",
        },

        {
            "gss",
            function()
                require("substitute.range").word()
            end,
        },
        {
            "gs",
            function()
                require("substitute.range").operator()
            end,
        },
        {
            "gs",
            function()
                require("substitute.range").visual()
            end,
            mode = "x",
        },

        {
            "sx",
            function()
                require("substitute.exchange").operator()
            end,
        },
        {
            "sxx",
            function()
                require("substitute.exchange").line()
            end,
        },
        {
            "sxc",
            function()
                require("substitute.exchange").cancel()
            end,
        },
        {
            "X",
            function()
                require("substitute.exchange").visual()
            end,
            mode = "x",
        },
    },
    opts = {},
}
