local function get_keys()
    local keys = {
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
