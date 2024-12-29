return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        indent = {
            char = "│", -- 缩进线字符
        },
        scope = { show_start = false, show_end = false },
    },
}
