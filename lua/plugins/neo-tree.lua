return {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    opts = function()
        local command = require("neo-tree.command")

        vim.keymap.set("n", "<Leader>w", function()
            command.execute({ action = "show", toggle = true })
        end, { desc = "Toggle Neo Tree" })

        vim.keymap.set("n", "<Leader>W", function()
            command.execute({ reveal = true })
        end, { desc = "Neo Tree Find File" })

        return {
            use_default_mappings = false,
            default_component_configs = {
                modified = {
                    symbol = "●",
                },
                git_status = {
                    symbols = {
                        added = "",
                        modified = "",
                        deleted = "",
                        renamed = "➜",

                        untracked = "?",
                        ignored = "◌",
                        unstaged = "✗",
                        staged = "✓",
                        conflict = "",
                    },
                },
            },
            window = {
                width = 32,
                mappings = {
                    ["<CR>"] = "open",
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["<ESC>"] = "cancel",

                    ["<C-v>"] = "open_vsplit",
                    ["<C-x>"] = "open_split",
                    ["<C-t>"] = "open_tabnew",
                    ["P"] = {
                        "toggle_preview",
                        config = {
                            use_float = true,
                            use_snacks_image = true,
                            use_image_nvim = true,
                        },
                    },
                    ["<C-u>"] = { "scroll_preview", config = { direction = 10 } },
                    ["<C-d>"] = { "scroll_preview", config = { direction = -10 } },

                    ["zM"] = "close_all_nodes",
                    ["zC"] = "close_all_subnodes",
                    ["zR"] = "expand_all_nodes",
                    ["zO"] = "expand_all_subnodes",

                    ["a"] = { "add", config = { show_path = "relative" } },
                    ["A"] = "add_directory",
                    ["DD"] = "delete",
                    ["r"] = "rename",
                    ["Rb"] = "rename_basename",

                    ["yy"] = "copy_to_clipboard",
                    ["dd"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",

                    ["g?"] = "show_help",

                    ["c"] = "copy",
                    ["m"] = "move",

                    ["RR"] = "refresh",

                    ["<"] = "prev_source",
                    [">"] = "next_source",

                    ["K"] = "show_file_details",
                },
            },
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_by_pattern = {
                        "*.git",
                    },
                },
                window = {
                    mappings = {
                        ["-"] = "navigate_up",
                        ["e"] = "set_root",
                        ["H"] = "toggle_hidden",
                        ["f"] = "fuzzy_finder",
                        ["F"] = "fuzzy_finder_directory",
                        ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
                        -- ["D"] = "fuzzy_sorter_directory",
                        ["S"] = "filter_on_submit",
                        ["<C-x>"] = "clear_filter",

                        ["[h"] = "prev_git_modified",
                        ["]h"] = "next_git_modified",

                        ["o"] = {
                            "show_help",
                            nowait = false,
                            config = { title = "Order by", prefix_key = "o" },
                        },
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["og"] = { "order_by_git_status", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                        -- ['<key>'] = function(state) ... end,
                    },
                    fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
                        ["<DOWN>"] = "move_cursor_down",
                        ["<C-j>"] = "move_cursor_down",
                        ["<UP>"] = "move_cursor_up",
                        ["<C-k>"] = "move_cursor_up",
                        ["<ESC>"] = "close",
                        ["<S-CR>"] = "close_keep_filter",
                        ["<C-CR>"] = "close_clear_filter",

                        ["<C-w>"] = { "<C-S-w>", raw = true },
                        ["<C-a>"] = { "<HOME>", raw = true },
                        ["<C-e>"] = { "<END>", raw = true },
                    },
                },
            },
            buffers = {
                window = {
                    mappings = {
                        ["dd"] = "buffer_delete",
                        ["-"] = "navigate_up",
                        ["e"] = "set_root",

                        ["o"] = {
                            "show_help",
                            nowait = false,
                            config = { title = "Order by", prefix_key = "o" },
                        },
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                    },
                },
            },
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["S"] = "git_add_all",
                        ["u"] = "git_unstage_file",
                        ["gU"] = "git_undo_last_commit",
                        ["s"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",

                        ["o"] = {
                            "show_help",
                            nowait = false,
                            config = { title = "Order by", prefix_key = "o" },
                        },
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                    },
                },
            },
        }
    end,
}
