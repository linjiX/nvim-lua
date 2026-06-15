local R = require("config.utility").lazy_require
local groups = R("bufferline.groups")
local bufferline = R("bufferline")

local function get_keys()
    local keys = {
        {
            "<Leader>bp",
            groups.toggle_pin(),
            desc = "Toggle Pin Buffer",
        },
        {
            "<Leader>bP",
            groups.action("pinned", "close"),
            desc = "Close Pinned Buffers",
        },
        {
            "<Leader>bU",
            groups.action("ungrouped", "close"),
            desc = "Close Ungrouped Buffers",
        },
        {
            "<Leader>bE",
            groups.action("external", "close"),
            desc = "Close External Buffers",
        },
        {
            "<Leader>bl",
            bufferline.close_in_direction("right"),
            desc = "Close Buffers to the Right",
        },
        {
            "<Leader>bh",
            bufferline.close_in_direction("left"),
            desc = "Close Buffers to the Left",
        },
        {
            "<Leader>bo",
            bufferline.close_others(),
            desc = "Close Other Buffers",
        },
        {
            "<Leader>bb",
            bufferline.pick(),
            desc = "Pick Buffers",
        },
        {
            "<Leader>bB",
            bufferline.close_with_pick(),
            desc = "Close Buffers with Pick",
        },
        {
            "<M-h>",
            bufferline.cycle(-1),
            mode = { "n", "x" },
            desc = "Prev Buffer",
        },
        {
            "<M-l>",
            bufferline.cycle(1),
            mode = { "n", "x" },
            desc = "Next Buffer",
        },
        {
            "<M-H>",
            bufferline.move(-1),
            mode = { "n", "x" },
            desc = "Move buffer prev",
        },
        {
            "<M-L>",
            bufferline.move(1),
            mode = { "n", "x" },
            desc = "Move buffer next",
        },
    }

    for i = 1, 10 do
        table.insert(keys, {
            ("<Leader>%d"):format(i == 10 and 0 or i),
            bufferline.go_to(i, true),
            desc = ("Go To Buffer %d"):format(i),
        })
    end

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

        vim.api.nvim_create_autocmd("BufAdd", {
            group = vim.api.nvim_create_augroup("MyBufferLine", { clear = true }),
            pattern = "*",
            callback = function(opts)
                local state = require("bufferline.state")
                local utils = require("bufferline.utils")

                if not state.custom_sort then
                    local maxbuf = 0
                    for _, component in ipairs(state.components) do
                        if component.id > maxbuf then
                            maxbuf = component.id
                        end
                    end

                    if opts.buf > maxbuf then
                        return
                    end
                    state.custom_sort = utils.get_ids(state.components)
                end

                for i, value in ipairs(state.custom_sort) do
                    if value == opts.buf then
                        table.remove(state.custom_sort, i)
                        break
                    end
                end

                table.insert(state.custom_sort, opts.buf)
            end,
        })

        local bufferline_groups = require("bufferline.groups")

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
                groups = {
                    items = {
                        bufferline_groups.builtin.ungrouped,
                        {
                            name = "external",
                            icon = " ",
                            separator = {
                                style = bufferline_groups.separator.none,
                            },
                            matcher = function(buf)
                                local cwd = vim.fn.getcwd()
                                local root = vim.fs.root(cwd, ".git") or cwd
                                return buf.buftype == ""
                                    and buf.path ~= ""
                                    and vim.fs.relpath(root, buf.path) == nil
                            end,
                        },
                    },
                },
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Title",
                    },
                    {
                        filetype = "aerial",
                        text = "Symbols",
                        highlight = "Title",
                    },
                    {
                        filetype = "fugitiveblame",
                        text = "Git Blame",
                        highlight = "Title",
                    },
                    {
                        filetype = "gitsigns-blame",
                        text = "Git Blame",
                        highlight = "Title",
                    },
                },
            },
        }
    end,
}
