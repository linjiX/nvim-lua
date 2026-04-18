local capitalize = require("config.utility").capitalize

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = function()
        vim.opt.showmode = false
        vim.opt.ruler = false

        local function get_title()
            local filetype = vim.bo.filetype
            return capitalize(filetype)
        end

        local function get_sidekick_cli_name()
            local cli = vim.b.sidekick_cli or vim.w.sidekick_cli
            return cli and capitalize(cli.name) or "Sidekick"
        end

        return {
            options = {
                disabled_filetypes = {
                    statusline = {
                        "snacks_dashboard",
                        "NvimTree",
                        "fugitiveblame",
                        "aerial",
                        "trouble",
                    },
                },
            },
            sections = {
                lualine_b = {
                    "branch",
                    {
                        "diff",
                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                    {
                        "diagnostics",
                        symbols = require("config.diagnostic").icons,
                    },
                },
                lualine_c = { "aerial" },
                lualine_x = {
                    {
                        "copilot",
                        show_colors = true,
                    },
                    {
                        "encoding",
                        fmt = function(encoding)
                            return encoding ~= "utf-8" and encoding or ""
                        end,
                    },
                    {
                        "fileformat",
                        symbols = {
                            unix = "",
                        },
                    },
                    "filetype",
                },
                lualine_y = { "selectioncount", "progress" },
            },
            extensions = {
                "quickfix",
                {
                    filetypes = { "fugitive" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_b = require("lualine.extensions.fugitive").sections.lualine_a,
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "floggraph" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_b = { "branch" },
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "undotree" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "diff", "man" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_x = { "filetype" },
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "help" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_c = { "filename" },
                        lualine_x = { "filetype" },
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "toggleterm" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_y = { "selectioncount", "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "sidekick_terminal" },
                    sections = {
                        lualine_a = { get_sidekick_cli_name },
                    },
                },
            },
        }
    end,
}
