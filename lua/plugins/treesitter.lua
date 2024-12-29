return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua",
                "vim",
                "regex",
                "bash",
                "vue",
                "html",
                "javascript",
                "typescript",
                "css",
                "scss",
                "python",
                "markdown",
                "json",
                "jsonc",
                "yaml",
                "toml",
                "gitcommit",
                "git_config",
                "gitignore",
            },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            incremental_selection = {
                enable = false,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                    scope_incremental = "<TAB>",
                },
            },

            indent = {
                enable = true,
            },
        })

        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldenable = false
        vim.opt.foldlevel = 99
    end,
}
