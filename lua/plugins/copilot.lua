return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        keys = {
            {
                "<Tab>",
                function()
                    if not require("copilot.suggestion").is_visible() then
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
                            "n",
                            false
                        )
                        return
                    end

                    require("copilot.suggestion").accept()
                end,
                mode = "i",
                desc = "Accept Copilot Suggestion",
            },
            {
                "<C-e>",
                function()
                    if not require("copilot.suggestion").is_visible() then
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes("<C-e>", true, false, true),
                            "n",
                            false
                        )
                        return
                    end

                    require("copilot.suggestion").dismiss()
                end,
                mode = "i",
                desc = "Dismiss Copilot Suggestion",
            },
            {
                "[rg",
                function()
                    require("copilot.command").enable()
                end,
                desc = "Enable Copilot",
            },
            {
                "]rg",
                function()
                    require("copilot.command").disable()
                end,
                desc = "Disable Copilot",
            },
            {
                "yrg",
                function()
                    require("copilot.command").toggle()
                end,
                desc = "Toggle Copilot",
            },
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
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                gitcommit = true,
            },
            copilot_model = "claude-sonnet-4",
        },
    },
    {
        "AndreM222/copilot-lualine",
    },
}
