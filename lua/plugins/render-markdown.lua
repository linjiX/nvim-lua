local filetypes = { "markdown", "Avante" }

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
        overrides = {
            filetype = {
                ["Avante"] = {
                    anti_conceal = {
                        enabled = false,
                    },
                },
            },
        },
    },
}
