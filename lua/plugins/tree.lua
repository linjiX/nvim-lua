vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
    "nvim-tree/nvim-tree.lua",
    keys = {
        { "<Leader>w", ":NvimTreeToggle<CR>", desc = "Toggle Nvim Tree" },
        { "<Leader>W", ":NvimTreeFindFile<CR>", desc = "Nvim Tree Find File" },
    },
    opts = function()
        vim.opt.termguicolors = true

        local function my_on_attach(bufnr)
            local api = require("nvim-tree.api")

            local keys = {
                { "g?", api.tree.toggle_help, "Help" },

                { "h", api.node.navigate.parent_close, "Close Directory" },
                { "l", api.node.open.edit, "Open" },
                { "<CR>", api.node.open.edit, "Open" },

                { "a", api.fs.create, "Create File Or Directory" },
                { "o", api.node.run.system, "Run System" },
                { ";", api.node.run.cmd, "Run Command" },

                { "e", api.tree.change_root_to_node, "CD" },
                { "-", api.tree.change_root_to_parent, "Up" },

                { "K", api.node.show_info_popup, "Info" },

                -- { "<C-j>", api.node.navigate.sibling.next, "Next Sibling" },
                -- { "<C-k>", api.node.navigate.sibling.prev, "Previous Sibling" },

                { "<C-v>", api.node.open.vertical, "Open: Vertical Split" },
                { "<C-x>", api.node.open.horizontal, "Open: Horizontal Split" },
                { "<C-t>", api.node.open.tab, "Open: New Tab" },
                { "<C-p>", api.node.open.preview, "Open: Preview" },

                { "dd", api.fs.cut, "Cut" },
                { "dD", api.fs.trash, "Trash" },
                { "DD", api.fs.remove, "Delete" },

                { "yy", api.fs.copy.node, "Copy" },
                { "yf", api.fs.copy.filename, "Copy Name" },
                { "yb", api.fs.copy.basename, "Copy Basename" },
                { "ya", api.fs.copy.absolute_path, "Copy Absolute Path" },
                { "yr", api.fs.copy.relative_path, "Copy Relative Path" },

                { "p", api.fs.paste, "Paste" },
                { "r", api.fs.rename, "Rename" },
                { "Rb", api.fs.rename_basename, "Rename: Basename" },
                { "Ra", api.fs.rename_full, "Rename: Absolute Path" },
                { "Rs", api.fs.rename_sub, "Rename: Omit Filename" },

                { "q", api.tree.close, "Close" },
                { "RR", api.tree.reload, "Refresh" },

                { "s", api.tree.search_node, "Search" },
                { "f", api.live_filter.start, "Live Filter: Start" },
                { "F", api.live_filter.clear, "Live Filter: Clean" },

                { "H", api.tree.toggle_hidden_filter, "Toggle Filter: Hidden" },
                { "B", api.tree.toggle_no_buffer_filter, "Toggle Filter: Buffer" },
                { "M", api.tree.toggle_no_bookmark_filter, "Toggle Filter: Bookmark" },
                { "I", api.tree.toggle_gitignore_filter, "Toggle Filter: Git Ignore" },
                { "G", api.tree.toggle_git_clean_filter, "Toggle Filter: Git Clean" },
                { "C", api.tree.toggle_custom_filter, "Toggle Filter: Custom" },

                { "zO", api.tree.expand_all, "Expand All" },
                { "zC", api.tree.collapse_all, "Collapse All" },

                { "[c", api.node.navigate.git.prev, "Prev Git" },
                { "]c", api.node.navigate.git.next, "Next Git" },
                { "[d", api.node.navigate.diagnostics.next, "Prev Diagnostics" },
                { "]d", api.node.navigate.diagnostics.prev, "Next Diagnostics" },
            }

            for _, key in ipairs(keys) do
                local lhs, rhs, desc = unpack(key)
                vim.keymap.set(
                    "n",
                    lhs,
                    rhs,
                    { desc = ("nvim-tree: %s"):format(desc), buffer = bufnr, nowait = true }
                )
            end
        end

        return {
            on_attach = my_on_attach,
            renderer = {
                indent_markers = {
                    enable = true,
                },
            },
            diagnostics = {
                enable = true,
            },
            system_open = {
                cmd = "open",
            },
            filters = {
                custom = { "^\\.git" },
            },
            actions = {
                file_popup = {
                    open_win_config = {
                        border = "rounded",
                    },
                },
            },
        }
    end,
}
