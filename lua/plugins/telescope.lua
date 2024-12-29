return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    opts = {
        defaults = {
            mappings = {
                i = {
                    ["<ESC>"] = "close",

                    ["<C-a>"] = { "<HOME>", type = "command" },
                    ["<C-e>"] = { "<END>", type = "command" },

                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                },
                n = {
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                },
            },
        },
    },
    keys = {
        { "<Leader>ff", require("telescope.builtin").find_files },
        { "<Leader>fm", require("telescope.builtin").oldfiles },
        { "<Leader>fr", require("telescope.builtin").live_grep },
        { "<Leader>fb", require("telescope.builtin").buffers },
        { "<Leader>fh", require("telescope.builtin").help_tags },
        { "<Leader>fe", require("telescope.builtin").filetypes },
        { "<Leader>fc", require("telescope.builtin").colorscheme },

        { "gd", require("telescope.builtin").lsp_definitions },
        { "<Leader>jj", require("telescope.builtin").lsp_definitions },
        {
            "<Leader>jr",
            function()
                require("telescope.builtin").lsp_references({ include_declaration = false })
            end,
        },
        { "<Leader>ji", require("telescope.builtin").lsp_implementations },
        { "<Leader>jt", require("telescope.builtin").lsp_type_definitions },

        { "<Leader>fo", require("telescope.builtin").resume },
    },
}
