local python_path = nil
local function python_path_getter()
    if not python_path then
        python_path = require("utility").get_python_path()
    end
    return python_path
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        vim.list_extend(lint.linters.mypy.args, { "--python-executable", python_path_getter })

        lint.linters_by_ft = {
            lua = { "luacheck" },
            python = { "mypy" },
            html = { "htmlhint" },
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            vue = { "eslint_d" },
            gitcommit = { "gitlint" },
        }

        local MyLint = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            group = MyLint,
            callback = function()
                lint.try_lint()
            end,
        })
        vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
            group = MyLint,
            callback = function()
                local linters = lint.linters_by_ft[vim.bo.filetype]
                if not linters then
                    return
                end

                local names = vim.tbl_filter(function(name)
                    return lint.linters[name].stdin
                end, linters)

                if #names > 0 then
                    lint.try_lint(names)
                end
            end,
        })
    end,
}
