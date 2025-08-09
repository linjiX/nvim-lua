return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = function()
        vim.opt.guicursor = { "n-v-sm:block", "i-ci-c-ve:ver25", "r-cr-o:hor20" }

        return {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = {
                    silent = true,
                },
            },
            presets = {
                bottom_search = false,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
            messages = {
                view_search = false,
            },
            routes = {
                {
                    filter = { event = "msg_show", kind = "shell_out" },
                    view = "notify",
                    opts = { level = "info", title = "stdout" },
                },
                {
                    filter = { event = "msg_show", kind = "shell_err" },
                    view = "notify",
                    opts = { level = "error", title = "stderr" },
                },
            },
        }
    end,
}
