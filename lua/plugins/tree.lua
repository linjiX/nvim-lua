vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
    "nvim-tree/nvim-tree.lua",
    keys = {
        { "<Leader>w", ":NvimTreeToggle<CR>", desc = "Toggle Nvim Tree" },
        { "<Leader>W", ":NvimTreeFindFile<CR>", desc = "Nvim Tree Find File" },
    },
    opts = function()
        vim.opt.termguicolors = true

        return {
            renderer = {
                indent_markers = {
                    enable = true,
                },
            },
            diagnostics = {
                enable = true,
            },
            system_open = {
                cmd = "open",
            },
            filters = {
                custom = { "^\\.git" },
            },
            actions = {
                file_popup = {
                    open_win_config = {
                        border = "rounded",
                    },
                },
            },
        }
    end,
}
