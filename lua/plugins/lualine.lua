return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = function()
        vim.opt.showmode = false
        return {
            sections = {
                lualine_x = {
                    { "copilot", show_colors = true },
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
        }
    end,
}
