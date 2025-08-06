local window = require("utility.window")
local R = require("utility").lazy_require

return {
    "yetone/avante.nvim",
    version = false,
    build = "make",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim",
        "hrsh7th/nvim-cmp",
        "nvim-tree/nvim-web-devicons",
        "zbirenbaum/copilot.lua",
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
    keys = {
        { "<Leader>aa", vim.cmd.AvanteAsk, mode = { "n", "x" } },
        { "<Leader>ac", vim.cmd.AvanteChat },
        { "<Leader>al", vim.cmd.AvanteClear },
        { "<Leader>aq", R("avante").close_sidebar() },
        { "<C-a>", "<HOME>", mode = "i", ft = { "AvanteInput" } },
        { "<C-e>", "<END>", mode = "i", ft = { "AvanteInput" } },
    },
    opts = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("AvanteMapping", { clear = true }),
            pattern = "Avante*",
            callback = function()
                window.set_quit_keymaps(require("avante").close_sidebar)
            end,
        })

        return {
            provider = "copilot",
            providers = {
                copilot = {
                    model = "claude-sonnet-4",
                },
            },
            auto_suggestions_provider = "copilot",
            hints = { enabled = false },
            mappings = {
                diff = {
                    ours = "ck",
                    theirs = "cj",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                },
                sidebar = {
                    switch_windows = "<C-j>",
                    reverse_switch_windows = "<C-k>",
                    add_file = "a",
                    remove_file = "dd",
                    close = {},
                    close_from_input = {
                        insert = "<C-d>",
                    },
                },
                files = {
                    add_current = "<Leader>A",
                },
            },
            windows = {
                ask = {
                    start_insert = false,
                },
            },
            file_selector = {
                provider = "telescope",
            },
        }
    end,
}
