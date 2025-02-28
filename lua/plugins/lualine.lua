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
                    { "copilot", show_colors = true },
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
            extensions = {
                "quickfix",
                "fugitive",
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
                        lualine_a = {
                            function()
                                return "Undotree"
                            end,
                        },
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
