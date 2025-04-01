local R = require("config.utility").lazy_require

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-smart-history.nvim", dependencies = "kkharji/sqlite.lua" },
    },
    cmd = "Telescope",
    keys = {
        { "<Leader>ff", R("telescope.builtin").find_files({ hidden = true }) },
        { "<Leader>fo", R("telescope.builtin").oldfiles({ only_cwd = true }) },
        { "<Leader>fO", R("telescope.builtin").oldfiles() },
        { "<Leader>fg", R("telescope.builtin").live_grep() },
        {
            "<Leader>fG",
            R("telescope.builtin").grep_string({
                search = "",
                word_match = "-w",
                only_sort_text = true,
            }),
        },
        { "<Leader>fb", R("telescope.builtin").buffers() },
        { "<Leader>fh", R("telescope.builtin").help_tags() },
        { "<Leader>fe", R("telescope.builtin").filetypes() },
        { "<Leader>fc", R("telescope.builtin").colorscheme() },
        { "<Leader>fw", R("telescope.builtin").grep_string() },
        { "<Leader>fs", R("telescope.builtin").builtin() },
        { "<Leader>fd", R("telescope.builtin").diagnostics() },
        { "<Leader>fl", R("telescope.builtin").current_buffer_fuzzy_find() },
        { "<Leader>fr", R("telescope.builtin").resume() },

        { "<Leader>gb", R("telescope.builtin").git_branches() },
        { "<Leader>gl", R("telescope.builtin").git_bcommits() },
        { "<Leader>gL", R("telescope.builtin").git_commits() },
        { "<Leader>gf", R("telescope.builtin").git_status() },
        { "<Leader>gF", R("telescope.builtin").git_files() },
        { "<Leader>gs", R("telescope.builtin").git_stash() },

        { "gd", R("telescope.builtin").lsp_definitions() },
        { "<Leader>jj", R("telescope.builtin").lsp_definitions() },
        { "<Leader>jr", R("telescope.builtin").lsp_references({ include_declaration = false }) },
        {
            "<Leader>js",
            R("telescope.builtin").lsp_document_symbols({
                symbols = {
                    "function",
                    "class",
                },
            }),
        },
        {
            "<Leader>jS",
            R("telescope.builtin").lsp_dynamic_workspace_symbols({
                symbols = {
                    "function",
                    "class",
                },
            }),
        },
        { "<Leader>ji", R("telescope.builtin").lsp_implementations() },
        { "<Leader>jt", R("telescope.builtin").lsp_type_definitions() },
    },
    opts = function()
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("smart_history")
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

                        ["<C-n>"] = "cycle_history_next",
                        ["<C-p>"] = "cycle_history_prev",

                        ["<C-l>"] = open_with_trouble,
                    },
                    n = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                    },
                },
                file_ignore_patterns = {
                    ".git/",
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
