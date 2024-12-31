return {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
        return {
            mappings = {
                around_next = "an",
                inside_next = "in",
                around_last = "aN",
                inside_last = "iN",
            },

            custom_textobjects = {
                l = function()
                    local line = vim.fn.line(".")
                    local text = vim.fn.getline(".")

                    return {
                        from = {
                            line = line,
                            col = vim.fn.match(text, "\\S") + 1,
                        },
                        to = {
                            line = line,
                            col = vim.fn.match(text, "\\s*$"),
                        },
                    }
                end,
                e = function()
                    return {
                        from = { line = 1, col = 1 },
                        to = { line = vim.fn.line("$"), col = 1 },
                        vis_mode = "V",
                    }
                end,
                d = { "%f[%d]%d+" },
            },
            n_lines = 500,
        }
    end,
}
