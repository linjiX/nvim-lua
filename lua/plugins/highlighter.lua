local ESC = vim.keycode("<ESC>")

return {
    "azabiong/vim-highlighter",
    cmd = { "Hi" },
    keys = {
        {
            "<Leader>k",
            function()
                vim.cmd.Hi("+")
            end,
            mode = "n",
            desc = "Highlight word",
        },
        {
            "<Leader>k",
            function()
                vim.cmd.normal(ESC)
                vim.cmd.Hi("+x")
            end,
            mode = "x",
            desc = "Highlight selection",
        },
        {
            "<Leader>*",
            function()
                vim.cmd.Hi("-")
            end,
            mode = "n",
            desc = "Highlight word onetime",
        },
        {
            "<Leader>*",
            function()
                vim.cmd.normal(ESC)
                vim.cmd.Hi("-x")
            end,
            mode = "x",
            desc = "Highlight selection onetime",
        },
        {
            "<Leader>#",
            function()
                vim.cmd.Hi("+%")
            end,
            mode = "n",
            desc = "Highlight word positional",
        },
        {
            "<Leader>#",
            function()
                vim.cmd.normal(ESC)
                vim.cmd.Hi("+x%")
            end,
            mode = "x",
            desc = "Highlight selection positional",
        },
    },
    config = function()
        vim.g.HiMapKeys = 0
        vim.g.HiSetToggle = 1

        local maps = {
            { key = "<Leader><BS>", cmd = "clear", desc = "Clear Highlight" },
            { key = "<Leader>n", cmd = "}", desc = "Next Highlight" },
            { key = "<Leader>N", cmd = "{", desc = "Previous Highlight" },
            { key = "]k", cmd = ">", desc = "Next Highlight Pattern" },
            { key = "[k", cmd = "<", desc = "Previous Highlight Pattern" },
        }

        for _, map in ipairs(maps) do
            vim.keymap.set("n", map.key, function()
                vim.cmd.Hi(map.cmd)
            end, { desc = map.desc })
        end

        vim.keymap.set("n", "<BS>", function()
            vim.cmd.nohlsearch()
            vim.cmd.Hi("clear")
        end, { desc = "Clear All Highlight" })
    end,
}
