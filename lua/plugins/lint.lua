return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            lua = { "luacheck" },
            python = { "mypy" },
            html = { "htmllint" },
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            vue = { "eslint_d" },
            gitcommit = { "gitlint" },
        }

        vim.api.nvim_create_autocmd(
            { "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" },
            {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            }
        )
    end,
}
