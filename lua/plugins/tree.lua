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

        return {}
    end,
}
