return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function()
        vim.opt.guicursor = { "n-v-sm:block", "i-ci-c-ve:ver25", "r-cr-o:hor20" }
        -- vim.opt.guicursor = {
        --     "n-v-c:block",
        --     "i-ci-ve:ver25",
        --     "r-cr:hor20",
        --     "o:hor50",
        --     "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
        --     "sm:block-blinkwait175-blinkoff150-blinkon175",
        -- }

        return {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
            messages = {
                view_search = false, -- 禁用默认的搜索视图
            },
        }
    end,
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        -- "rcarriga/nvim-notify",
    },
}
