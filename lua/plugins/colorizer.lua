local R = require("config.utility").lazy_require
local colorizer = R("colorizer")

local ft = { "vue", "javascript", "typescript", "html", "css", "lua" }

return {
    "norcalli/nvim-colorizer.lua",
    ft = ft,
    cmd = "Colorizer",
    keys = {
        {
            "[rh",
            colorizer.attach_to_buffer(0),
            desc = "Disable Colorizer",
        },
        {
            "]rh",
            colorizer.detach_from_buffer(0),
            desc = "Enable Colorizer",
        },
        {
            "yrh",
            function()
                if colorizer.is_buffer_attached(0)() then
                    colorizer.detach_from_buffer(0)()
                else
                    colorizer.attach_to_buffer(0)()
                end
            end,
            desc = "Toggle Colorizer",
        },
        {
            "yrH",
            colorizer.reload_all_buffers(),
            desc = "Reload Colorizer",
        },
    },
    opts = function()
        vim.opt.termguicolors = true

        return ft
    end,
}
