return {
    "kevinhwang91/nvim-hlslens",
    keys = {
        {
            "n",
            function()
                require("hlslens").nNPeekWithUFO("n")
            end,
            mode = { "n", "x" },
            desc = "Next search result with hlslens",
        },
        {
            "N",
            function()
                require("hlslens").nNPeekWithUFO("N")
            end,
            mode = { "n", "x" },
            desc = "Previous search result with hlslens",
        },
        {
            "*",
            function()
                require("config.star").star("*")
                require("hlslens").start()
            end,
            desc = "Search word under cursor forward",
        },
        {
            "#",
            function()
                require("config.star").star("#")
                require("hlslens").start()
            end,
            desc = "Search word under cursor backward",
        },
        {
            "g*",
            function()
                require("config.star").star("g*")
                require("hlslens").start()
            end,
            desc = "Search word under cursor forward (partial)",
        },
        {
            "g#",
            function()
                require("config.star").star("g#")
                require("hlslens").start()
            end,
            desc = "Search word under cursor backward (partial)",
        },
        {
            "*",
            function()
                require("config.star").visual_star("*")
                require("hlslens").start()
            end,
            mode = "x",
            desc = "Search visual selection forward",
        },
        {
            "#",
            function()
                require("config.star").visual_star("#")
                require("hlslens").start()
            end,
            mode = "x",
            desc = "Search visual selection backward",
        },
    },
    opts = function()
        vim.api.nvim_set_hl(0, "HlSearchNear", { link = "None", default = true })
        vim.api.nvim_set_hl(0, "HlSearchLens", { link = "DiagnosticUnnecessary", default = true })
        vim.api.nvim_set_hl(0, "HlSearchLensNear", { link = "DiagnosticInfo", default = true })

        local ok, scrollbar = pcall(require, "scrollbar.handlers.search")
        if ok then
            scrollbar.setup()
        end

        return {}
    end,
}
