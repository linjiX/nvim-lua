return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
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
            "vue",
            "yaml",
        })

        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldenable = false
        vim.opt.foldlevel = 99
    end,
}
