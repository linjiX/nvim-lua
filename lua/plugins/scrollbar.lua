return {
    "petertriho/nvim-scrollbar",
    config = function()
        require("scrollbar").setup({
            excluded_buftypes = {
                "nofile",
                "terminal",
                "prompt",
            },
            excluded_filetypes = {
                "fugitiveblame",
            },
        })
        require("scrollbar.handlers.gitsigns").setup()
    end,
}
