local R = require("utility").lazy_require
local telescope = R("telescope")
local builtin = R("telescope.builtin")

-- local symbols =
--     { "class", "constructor", "enum", "function", "interface", "module", "method", "struct" }
local ts_ignore = { ".d.ts$" }

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
        { "<Leader>ff", builtin.find_files({ hidden = true }) },
        { "<Leader>fo", builtin.oldfiles({ only_cwd = true }) },
        { "<Leader>fO", builtin.oldfiles() },
        { "<Leader>fg", builtin.live_grep() },
        {
            "<Leader>fG",
            builtin.grep_string({
                search = "",
                word_match = "-w",
                only_sort_text = true,
            }),
        },
        { "<Leader>fb", builtin.buffers({ ignore_current_buffer = true }) },
        { "<Leader>fh", builtin.help_tags() },
        { "<Leader>fH", builtin.highlights() },
        { "<Leader>fe", builtin.filetypes() },
        { "<Leader>fc", builtin.colorscheme() },
        { "<Leader>fw", builtin.grep_string(), mode = { "n", "x" } },
        { "<Leader>fs", builtin.builtin() },
        { "<Leader>fd", builtin.diagnostics({ bufnr = 0 }) },
        { "<Leader>fD", builtin.diagnostics() },
        { "<Leader>fl", builtin.current_buffer_fuzzy_find() },
        { "<Leader>fr", builtin.resume() },
        { "<Leader>fn", telescope.extensions.noice.noice() },

        {
            "<Leader>gb",
            builtin.git_branches({ show_remote_tracking_branches = false }),
        },
        { "<Leader>gB", builtin.git_branches() },
        { "<Leader>gl", builtin.git_bcommits() },
        { "<Leader>gl", builtin.git_bcommits_range(), mode = { "x" } },
        { "<Leader>gL", builtin.git_commits() },
        { "<Leader>gf", builtin.git_status() },
        { "<Leader>gF", builtin.git_files() },
        { "<Leader>gs", builtin.git_stash() },

        {
            "gd",
            builtin.lsp_definitions({ file_ignore_patterns = ts_ignore }),
        },
        {
            "grr",
            builtin.lsp_references({
                include_declaration = false,
                file_ignore_patterns = ts_ignore,
            }),
        },
        -- { "gO", builtin.lsp_document_symbols({ bufnr = 0, symbols = symbols }) },
        { "gO", telescope.extensions.aerial.aerial() },
        { "gri", builtin.lsp_implementations() },
        { "grt", builtin.lsp_type_definitions() },
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
