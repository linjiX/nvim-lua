local function hijack_find_textobject()
    local miniai = require("mini.ai")
    local find_textobject = miniai.find_textobject
    miniai.find_textobject = function(ai_type, id, opts)
        local result = find_textobject(ai_type, id, opts)
        if result ~= nil then
            result.from, result.to = result.to, result.from
        end
        return result
    end
end

return {
    "echasnovski/mini.ai",
    dependencies = "echasnovski/mini.extra",
    event = "VeryLazy",
    opts = function()
        hijack_find_textobject()

        local gen_ai_spec = require("mini.extra").gen_ai_spec

        return {
            mappings = {
                around_next = "an",
                inside_next = "in",
                around_last = "aN",
                inside_last = "iN",
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
