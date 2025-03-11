return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = function()
        vim.opt.showmode = false

        local trouble = require("trouble")
        local symbols = trouble.statusline({
            mode = "lsp_document_symbols",
            groups = {},
            title = false,
            filter = { range = true },
            format = "{kind_icon}{symbol.name:Normal}",
            hl_group = "lualine_c_normal",
        })

        local function get_title()
            local filetype = vim.bo.filetype
            return filetype:sub(1, 1):upper() .. filetype:sub(2):lower()
        end

        return {
            options = {
                disabled_filetypes = {
                    statusline = {
                        "snacks_dashboard",
                        "NvimTree",
                        "trouble",
                        "Avante",
                        "AvanteSelectedFiles",
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
                    "diagnostics",
                },
                lualine_c = {
                    "filename",
                    { symbols.get, cond = symbols.has },
                },
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
            },
            extensions = {
                "quickfix",
                {
                    filetypes = { "fugitive" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_b = require("lualine.extensions.fugitive").sections.lualine_a,
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "floggraph" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_b = { "branch" },
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "AvanteInput" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "undotree" },
                    sections = {
                        lualine_a = { get_title },
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "diff", "man" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_x = { "filetype" },
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
                {
                    filetypes = { "help" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_c = { "filename" },
                        lualine_x = { "filetype" },
                        lualine_y = { "progress" },
                        lualine_z = { "location" },
                    },
                },
            },
        }
    end,
}
