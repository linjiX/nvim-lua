return {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = "kkharji/sqlite.lua",
    keys = {
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
        { ">p", "<Plug>(YankyPutIndentAfterShiftRight)" },
        { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)" },
        { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)" },
        { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)" },
        { "=p", "<Plug>(YankyPutAfterFilter)" },
        { "=P", "<Plug>(YankyPutBeforeFilter)" },

        { "<C-p>", "<Plug>(YankyPreviousEntry)" },
        { "<C-n>", "<Plug>(YankyNextEntry)" },
    },
    opts = function()
        vim.api.nvim_set_hl(0, "YankyYanked", { link = "Search" })
        vim.api.nvim_set_hl(0, "YankyPut", { link = "Search" })

        local utils = require("yanky.utils")
        local mapping = require("yanky.telescope.mapping")

        return {
            ring = {
                storage = "sqlite",
            },
            picker = {
                telescope = {
                    use_default_mappings = false,
                    mappings = {
                        default = mapping.put("p"),
                        i = {
                            ["<c-x>"] = mapping.delete(),
                            ["<c-r>"] = mapping.set_register(utils.get_default_register()),
                        },
                        n = {
                            p = mapping.put("p"),
                            P = mapping.put("P"),
                            x = mapping.delete(),
                            r = mapping.set_register(utils.get_default_register()),
                        },
                    },
                },
            },
            highlight = {
                timer = 300,
            },
        }
    end,
}
