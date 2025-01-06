return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<Leader>a",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "isort", "pyupgrade", "black" },
            javascript = { "prettierd" },
            typescript = { "prettierd" },
            vue = { "prettierd" },
            json = { "prettierd" },
            jsonc = { "prettierd" },
            yaml = { "prettierd" },
            html = { "prettierd" },
            css = { "prettierd" },
            scss = { "prettierd" },
            markdown = { "prettierd" },
        },
        formatters = {
            pyupgrade = {
                command = "pyupgrade",
                args = { "--exit-zero-even-if-changed", "-" },
            },
        },
    },
}
