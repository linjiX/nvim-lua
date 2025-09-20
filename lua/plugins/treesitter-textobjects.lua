return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-treesitter.configs").setup({
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["am"] = {
                            query = "@function.outer",
                            desc = "outer function",
                        },
                        ["im"] = {
                            query = "@function.inner",
                            desc = "inner function",
                        },
                        ["an"] = {
                            query = "@class.outer",
                            desc = "outer class",
                        },
                        ["in"] = {
                            query = "@class.inner",
                            desc = "inner class",
                        },
                        ["aA"] = {
                            query = "@parameter.outer",
                            desc = "outer argument",
                        },
                        ["iA"] = {
                            query = "@parameter.inner",
                            desc = "inner argument",
                        },
                        ["ii"] = {
                            query = "@block.inner",
                            desc = "inner block",
                        },
                        ["ai"] = {
                            query = "@block.outer",
                            desc = "outer block",
                        },
                    },
                    selection_modes = {
                        ["@function.outer"] = "V",
                        ["@function.inner"] = "V",
                        ["@class.outer"] = "V",
                        ["@class.inner"] = "V",
                        ["@block.outer"] = "V",
                        ["@block.inner"] = "V",
                    },
                    include_surrounding_whitespace = function(info)
                        if info.query_string == "@parameter.outer" then
                            return true
                        end
                        return false
                    end,
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["]p"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["[p"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]n"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]N"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[n"] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[N"] = "@class.outer",
                    },
                },
            },
        })
    end,
}
