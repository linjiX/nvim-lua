return {
    "stevearc/aerial.nvim",
    cmd = { "AerialOpen", "AerialToggle" },
    opts = function()
        vim.api.nvim_set_hl(0, "AerialLine", { link = "CursorLineNr" })

        return {
            layout = {
                width = 32,
                win_opts = {
                    cursorline = true,
                    cursorcolumn = false,
                },
            },
            attach_mode = "global",
            keymaps = {
                ["<C-s>"] = false,
                ["<C-x>"] = "actions.jump_split",
                ["<C-j>"] = false,
                ["<C-k>"] = false,
                ["l"] = "actions.jump",
            },
            show_guides = true,
            guides = {
                mid_item = "├╴",
                last_item = "└╴",
                nested_top = "│ ",
                whitespace = "  ",
            },
            lsp = {
                diagnostics_trigger_update = true,
                priority = {
                    copilot = 0,
                    vue_ls = 20,
                },
            },
        }
    end,
}
