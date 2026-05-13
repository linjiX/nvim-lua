local command = require("config.utility").lazy_require("copilot.command")

return {
    "zbirenbaum/copilot.lua",
    dependencies = { "AndreM222/copilot-lualine" },
    cmd = "Copilot",
    event = "InsertEnter",
    keys = {
        {
            "<Tab>",
            function()
                local suggestion = require("copilot.suggestion")
                if not suggestion.is_visible() then
                    return "<Tab>"
                end

                suggestion.accept()
            end,
            expr = true,
            mode = "i",
            desc = "Accept Copilot Suggestion",
        },
        { "[rg", command.enable(), desc = "Enable Copilot" },
        { "]rg", command.disable(), desc = "Disable Copilot" },
        { "yrg", command.toggle(), desc = "Toggle Copilot" },
    },
    opts = {
        panel = {
            keymap = {
                jump_prev = "<C-k>",
                jump_next = "<C-j>",
                accept = "<CR>",
                refresh = "r",
                open = "<C-l>",
            },
            layout = {
                position = "right",
            },
        },
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = false,
                accept_word = false,
                accept_line = false,
                next = "<C-j>",
                prev = "<C-k>",
                dismiss = "<C-e>",
            },
        },
        filetypes = {
            gitcommit = true,
        },
    },
}
