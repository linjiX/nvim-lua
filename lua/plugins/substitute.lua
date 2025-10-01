local R = require("config.utility").lazy_require
local substitute = R("substitute")
local range = R("substitute.range")
local exchange = R("substitute.exchange")

return {
    "gbprod/substitute.nvim",
    keys = {
        { "s", substitute.operator(), desc = "Substitute" },
        { "ss", substitute.line(), desc = "Substitute line" },
        { "S", substitute.eol(), desc = "Substitute to end of line" },
        { "s", substitute.visual(), mode = "x", desc = "Substitute visual selection" },

        { "gss", range.word(), desc = "Range substitute for word" },
        { "gs", range.operator(), desc = "Range substitute" },
        { "gs", range.visual(), mode = "x", desc = "Range substitute" },

        { "sx", exchange.operator(), desc = "Exchange" },
        { "sxx", exchange.line(), desc = "Exchange line" },
        { "sxc", exchange.cancel(), desc = "Exchange cancel" },
        { "X", exchange.visual(), mode = "x", desc = "Exchange" },
    },
    opts = {},
}
