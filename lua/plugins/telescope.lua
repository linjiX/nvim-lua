local R = require("config.utility").lazy_require
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
        { "<Leader>ff", builtin.find_files({ hidden = true }), desc = "Files" },
        { "<Leader>fo", builtin.oldfiles({ only_cwd = true }), desc = "Recent Files" },
        { "<Leader>fO", builtin.oldfiles(), desc = "Recent Files (all)" },
        { "<Leader>fg", builtin.live_grep(), desc = "Live Grep" },
        {
            "<Leader>fG",
            builtin.grep_string({ search = "", word_match = "-w", only_sort_text = true }),
            desc = "Fuzzy Grep",
        },
        { "<Leader>fb", builtin.buffers({ ignore_current_buffer = true }), desc = "Buffers" },
        { "<Leader>fh", builtin.help_tags(), desc = "Help Tags" },
        { "<Leader>fm", builtin.man_pages(), desc = "Man pages" },
        { "<Leader>fH", builtin.highlights(), desc = "Highlights" },
        { "<Leader>fe", builtin.filetypes(), desc = "Filetypes" },
        { "<Leader>fc", builtin.colorscheme(), desc = "Colorschemes" },
        { "<Leader>fw", builtin.grep_string(), mode = { "n", "x" }, desc = "Cursor Word" },
        { "<Leader>fs", builtin.builtin(), desc = "Telescope Builtins" },
        { "<Leader>fd", builtin.diagnostics({ bufnr = 0 }), desc = "Diagnostics" },
        { "<Leader>fD", builtin.diagnostics(), desc = "Diagnostics (all)" },
        { "<Leader>fl", builtin.current_buffer_fuzzy_find(), desc = "Lines" },
        { "<Leader>fr", builtin.resume(), desc = "Resume" },
        { "<Leader>fn", telescope.extensions.noice.noice(), desc = "Noice" },

        {
            "<Leader>gb",
            builtin.git_branches({ show_remote_tracking_branches = false }),
            desc = "Git Branch",
        },
        { "<Leader>gB", builtin.git_branches(), desc = "Git Branch (all)" },
        { "<Leader>gl", builtin.git_bcommits(), desc = "Git Log (buffer)" },
        { "<Leader>gl", builtin.git_bcommits_range(), mode = "x", desc = "Git Log (range)" },
        { "<Leader>gL", builtin.git_commits(), desc = "Git Log" },
        { "<Leader>gf", builtin.git_status(), desc = "Git Status" },
        { "<Leader>gF", builtin.git_files(), desc = "Git Files" },
        { "<Leader>gs", builtin.git_stash(), desc = "Git Stash" },

        {
            "gd",
            builtin.lsp_definitions({ file_ignore_patterns = ts_ignore }),
            desc = "LSP Definition",
        },
        {
            "grr",
            builtin.lsp_references({
                include_declaration = false,
                file_ignore_patterns = ts_ignore,
            }),
            desc = "LSP References",
        },
        -- {
        --     "gO",
        --     builtin.lsp_document_symbols({ bufnr = 0, symbols = symbols }),
        --     desc = "LSP Document Symbols",
        -- },
        { "gO", telescope.extensions.aerial.aerial(), desc = "LSP Document Symbols" },
        { "gri", builtin.lsp_implementations(), desc = "LSP Implementations" },
        { "grt", builtin.lsp_type_definitions(), desc = "LSP Type Definitions" },
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
