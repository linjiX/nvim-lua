return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
        { "<Leader>ff", require("telescope.builtin").find_files },
        { "<Leader>fm", require("telescope.builtin").oldfiles },
        { "<Leader>fg", require("telescope.builtin").live_grep },
        {
            "<Leader>fG",
            function()
                require("telescope.builtin").grep_string({
                    search = "",
                    word_match = "-w",
                    only_sort_text = true,
                })
            end,
        },
        { "<Leader>fb", require("telescope.builtin").buffers },
        { "<Leader>fh", require("telescope.builtin").help_tags },
        { "<Leader>fe", require("telescope.builtin").filetypes },
        { "<Leader>fc", require("telescope.builtin").colorscheme },
        { "<Leader>fw", require("telescope.builtin").grep_string },
        { "<Leader>fs", require("telescope.builtin").builtin },
        { "<Leader>fd", require("telescope.builtin").diagnostics },
        { "<Leader>fl", require("telescope.builtin").current_buffer_fuzzy_find },
        { "<Leader>fr", require("telescope.builtin").resume },

        { "<Leader>gb", require("telescope.builtin").git_branches },
        { "<Leader>gl", require("telescope.builtin").git_bcommits },
        { "<Leader>gL", require("telescope.builtin").git_commits },
        { "<Leader>gf", require("telescope.builtin").git_status },
        { "<Leader>gF", require("telescope.builtin").git_files },
        { "<Leader>gs", require("telescope.builtin").git_stash },

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
    },
    opts = function()
        require("telescope").load_extension("fzf")
        local open_with_trouble = require("trouble.sources.telescope").open

        return {
            defaults = {
                mappings = {
                    i = {
                        ["<ESC>"] = "close",

                        ["<C-a>"] = { "<HOME>", type = "command" },
                        ["<C-e>"] = { "<END>", type = "command" },

                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",

                        ["<C-l>"] = open_with_trouble,
                    },
                    n = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                    },
                },
            },
            pickers = {
                live_grep = {
                    mappings = {
                        i = { ["<C-f>"] = require("telescope.actions").to_fuzzy_refine },
                    },
                },
            },
        }
    end,
}
