local python_path = nil
local function python_path_getter()
    if not python_path then
        python_path = require("config.utility").get_python_path()
    end
    return python_path
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters.dmypy.args = {
            "run",
            "--timeout",
            "3600",
            "--",
            "--show-column-numbers",
            "--show-error-end",
            "--hide-error-context",
            "--no-color-output",
            "--no-error-summary",
            "--no-pretty",
            "--python-executable",
            python_path_getter,
        }

        lint.linters_by_ft = {
            lua = { "luacheck" },
            python = { "dmypy" },
            html = { "htmlhint" },
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
