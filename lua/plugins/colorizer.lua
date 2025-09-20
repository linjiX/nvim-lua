local R = require("utility").lazy_require

local ft = { "vue", "javascript", "typescript", "html", "css", "lua" }

return {
    "norcalli/nvim-colorizer.lua",
    ft = ft,
    cmd = "Colorizer",
    keys = {
        {
            "[rh",
            R("colorizer").attach_to_buffer(0),
        },
        {
            "]rh",
            R("colorizer").detach_from_buffer(0),
        },
        {
            "yrh",
            function()
                local colorizer = require("colorizer")
                if colorizer.is_buffer_attached(0) then
                    colorizer.detach_from_buffer(0)
                else
                    colorizer.attach_to_buffer(0)
                end
            end,
        },
        {
            "yrH",
            R("colorizer").reload_all_buffers(),
        },
    },
    opts = function()
        vim.opt.termguicolors = true

        return ft
    end,
}
