return {
    "echasnovski/mini.ai",
    dependencies = "echasnovski/mini.extra",
    event = "VeryLazy",
    opts = function()
        local gen_ai_spec = require("mini.extra").gen_ai_spec

        return {
            mappings = {
                around_next = "",
                inside_next = "",
                around_last = "",
                inside_last = "",

                goto_left = "",
                goto_right = "",
            },

            custom_textobjects = {
                r = {
                    {
                        "%f[%w]%w-[-_#]",
                        "[-_#]%w-%f[^%w]",
                        "%f[-_#%w]%w-%f[^-_#%w]",
                        "%f[-_#%w]%w-%f[^-_#%l%d]",
                        "%f[-_#%u]%u%w-%f[^-_#%l%d]",
                    },
                    "^[-_#]?()%w*()[-_#]?$",
                },
                l = gen_ai_spec.line(),
                d = gen_ai_spec.number(),
                e = function()
                    return {
                        from = { line = 1, col = 1 },
                        to = { line = vim.fn.line("$"), col = 1 },
                        vis_mode = "V",
                    }
                end,
            },
            n_lines = 500,
        }
    end,
}
