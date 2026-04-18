local filetypes = { "markdown" }

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = filetypes,
    opts = {
        file_types = filetypes,
        code = {
            border = "thin",
        },
        completions = {
            lsp = {
                enabled = true,
            },
        },
    },
}
