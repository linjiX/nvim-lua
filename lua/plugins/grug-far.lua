return {
    "MagicDuck/grug-far.nvim",
    keys = {
        {
            "<Leader>ss",
            function()
                require("grug-far").open({
                    prefills = { search = ("\\<%s\\>"):format(vim.fn.expand("<cword>")) },
                    startInInsertMode = false,
                    startCursorRow = 3,
                    transient = true,
                })
            end,
            mode = "n",
            desc = "Search & Replace Current Word",
        },
        {
            "<Leader>ss",
            function()
                require("grug-far").with_visual_selection({
                    startInInsertMode = false,
                    startCursorRow = 3,
                    transient = true,
                })
            end,
            mode = "x",
            desc = "Search & Replace Visual Word",
        },
        {
            "<Leader>s<Space>",
            function()
                require("grug-far").open({ transient = true })
            end,
            mode = "n",
            desc = "Search & Replace",
        },
    },
    opts = {},
}
