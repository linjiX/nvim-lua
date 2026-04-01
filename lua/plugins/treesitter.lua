local parsers = {
    "bash",
    "css",
    "diff",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "regex",
    "scss",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "yaml",
}

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install(parsers)

        local filetypes = vim.iter(parsers)
            :map(function(parser)
                return vim.treesitter.language.get_filetypes(parser)
            end)
            :flatten()
            :totable()

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("MyTreesitter", { clear = true }),
            pattern = filetypes,
            callback = function()
                vim.treesitter.start()
                vim.opt_local.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
            end,
        })

        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldenable = false
        vim.opt.foldlevel = 99
    end,
}
