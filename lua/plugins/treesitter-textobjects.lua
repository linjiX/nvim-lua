local R = require("config.utility").lazy_require
local select = R("nvim-treesitter-textobjects.select")
local swap = R("nvim-treesitter-textobjects.swap")
local move = R("nvim-treesitter-textobjects.move")

return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
        {
            "am",
            select.select_textobject("@function.outer", "textobjects"),
            mode = { "x", "o" },
            desc = "outer function",
        },
        {
            "im",
            select.select_textobject("@function.inner", "textobjects"),
            mode = { "x", "o" },
            desc = "inner function",
        },
        {
            "an",
            select.select_textobject("@class.outer", "textobjects"),
            mode = { "x", "o" },
            desc = "outer class",
        },
        {
            "in",
            select.select_textobject("@class.inner", "textobjects"),
            mode = { "x", "o" },
            desc = "inner class",
        },
        {
            "aA",
            select.select_textobject("@parameter.outer", "textobjects"),
            mode = { "x", "o" },
            desc = "outer argument",
        },
        {
            "iA",
            select.select_textobject("@parameter.inner", "textobjects"),
            mode = { "x", "o" },
            desc = "inner argument",
        },
        {
            "ii",
            select.select_textobject("@block.inner", "textobjects"),
            mode = { "x", "o" },
            desc = "inner block",
        },
        {
            "ai",
            select.select_textobject("@block.outer", "textobjects"),
            mode = { "x", "o" },
            desc = "outer block",
        },
        {
            "]p",
            swap.swap_next("@parameter.inner", "textobjects"),
            desc = "swap next parameter",
        },
        {
            "[p",
            swap.swap_previous("@parameter.inner", "textobjects"),
            desc = "swap previous parameter",
        },
        {
            "]m",
            move.goto_next_start("@function.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "next function start",
        },
        {
            "]n",
            move.goto_next_start("@class.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "next class start",
        },
        {
            "]M",
            move.goto_next_end("@function.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "next function end",
        },
        {
            "]N",
            move.goto_next_end("@class.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "next class end",
        },
        {
            "[m",
            move.goto_previous_start("@function.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "previous function start",
        },
        {
            "[n",
            move.goto_previous_start("@class.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "previous class start",
        },
        {
            "[M",
            move.goto_previous_end("@function.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "previous function end",
        },
        {
            "[N",
            move.goto_previous_end("@class.outer", "textobjects"),
            mode = { "n", "x", "o" },
            desc = "previous class end",
        },
    },
    opts = {
        select = {
            lookahead = true,
            selection_modes = {
                ["@function.outer"] = "V",
                ["@function.inner"] = "V",
                ["@class.outer"] = "V",
                ["@class.inner"] = "V",
                ["@block.outer"] = "V",
                ["@block.inner"] = "V",
            },
            include_surrounding_whitespace = function(info)
                if info.query_string == "@parameter.outer" then
                    return true
                end
                return false
            end,
        },
        move = {
            set_jumps = true,
        },
    },
}
