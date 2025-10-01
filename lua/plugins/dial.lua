local map = require("utility").lazy_require("dial.map")

return {
    "monaqa/dial.nvim",
    keys = {
        {
            "<C-a>",
            map.manipulate("increment", "normal"),
            desc = "Dial Increment",
        },
        {
            "<C-x>",
            map.manipulate("decrement", "normal"),
            desc = "Dial Decrement",
        },
        {
            "g<C-a>",
            map.manipulate("increment", "gnormal"),
            desc = "Dial Increment Sequence",
        },
        {
            "g<C-x>",
            map.manipulate("decrement", "gnormal"),
            desc = "Dial Decrement Sequence",
        },
        {
            "<C-a>",
            map.manipulate("increment", "visual"),
            mode = "x",
            desc = "Dial Increment",
        },
        {
            "<C-x>",
            map.manipulate("decrement", "visual"),
            mode = "x",
            desc = "Dial Decrement",
        },
        {
            "g<C-a>",
            map.manipulate("increment", "gvisual"),
            mode = "x",
            desc = "Dial Increment Sequence",
        },
        {
            "g<C-x>",
            map.manipulate("decrement", "gvisual"),
            mode = "x",
            desc = "Dial Decrement Sequence",
        },
    },
    config = function()
        local augend = require("dial.augend")

        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.constant.alias.bool,
                augend.constant.new({ elements = { "True", "False" } }),
                augend.constant.new({ elements = { "TRUE", "FALSE" } }),
                augend.date.alias["%Y/%m/%d"],
                augend.date.alias["%Y-%m-%d"],
                augend.date.alias["%m/%d"],
                augend.date.alias["%H:%M"],
            },
        })
    end,
}
