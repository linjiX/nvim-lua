local function get_keys()
    local keys = {
        {
            "<Leader>bp",
            ":<C-u>BufferLineTogglePin<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Toggle Pin Buffer",
        },
        {
            "<Leader>bP",
            ":<C-u>BufferLineGroupClose ungrouped<CR>",
            silent = true,
            desc = "Close Upgrouped Buffers",
        },
        {
            "<Leader>bl",
            ":<C-u>BufferLineCloseRight<CR>",
            silent = true,
            desc = "Close Buffers to the Right",
        },
        {
            "<Leader>bh",
            ":<C-u>BufferLineCloseLeft<CR>",
            silent = true,
            desc = "Close Buffers to the Left",
        },
        {
            "<Leader>bo",
            ":<C-u>BufferLineCloseOthers<CR>",
            silent = true,
            desc = "Close Other Buffers",
        },
        {
            "<Leader>bb",
            ":<C-u>BufferLinePick<CR>",
            silent = true,
            desc = "Pick Buffers",
        },
        {
            "<M-h>",
            ":<C-u>BufferLineCyclePrev<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Prev Buffer",
        },
        {
            "<M-l>",
            ":<C-u>BufferLineCycleNext<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Next Buffer",
        },
        {
            "<M-H>",
            ":<C-u>BufferLineMovePrev<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Move buffer prev",
        },
        {
            "<M-L>",
            ":<C-u>BufferLineMoveNext<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Move buffer next",
        },
    }

    for i = 1, 9 do
        table.insert(keys, {
            ("<Leader>%d"):format(i),
            (":BufferLineGoToBuffer %d<CR>"):format(i),
            silent = true,
            desc = ("Go To Buffer %d"):format(i),
        })
    end

    table.insert(
        keys,
        { "<Leader>0", ":BufferLineGoToBuffer 10<CR>", silent = true, desc = "Go To Buffer 10" }
    )

    return keys
end

return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false,
    keys = get_keys(),
    opts = function()
        vim.opt.termguicolors = true

        return {
            options = {
                numbers = function(opts)
                    local state = require("bufferline.state")
                    for i, buf in ipairs(state.components) do
                        if buf.id == opts.id then
                            return opts.raise(i)
                        end
                    end
                    return opts.raise(opts.ordinal)
                end,
                show_buffer_close_icons = false,
                separator_style = "slant",
                diagnostics = "nvim_lsp",
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Title",
                    },
                },
            },
        }
    end,
}
