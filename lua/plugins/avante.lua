local window = require("config.window")
local R = require("config.utility").lazy_require
local api = R("avante.api")

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
        {
            "<Leader>aa",
            api.ask(),
            mode = { "n", "x" },
            desc = "avante: ask",
        },
        {
            "<Leader>ac",
            api.ask({ ask = false }),
            mode = { "n", "x" },
            desc = "avante: chat",
        },
        {
            "<Leader>an",
            api.ask({ new_chat = true }),
            mode = { "n", "x" },
            desc = "avante: new ask",
        },
        {
            "<Leader>ae",
            api.edit(),
            mode = "x",
            desc = "avante: edit",
        },
        {
            "<Leader>al",
            vim.cmd.AvanteClear,
            desc = "avante: clear",
        },
        {
            "<Leader>aq",
            R("avante").close_sidebar(),
            desc = "avante: quit",
        },
    },
    opts = function()
        local function insert_avante()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "AvanteInput" then
                    vim.api.nvim_set_current_win(win)
                    vim.cmd.startinsert()
                    return
                end
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("AvanteMapping", { clear = true }),
            pattern = "Avante*",
            callback = function()
                window.set_quit_keymaps(require("avante").close_sidebar)

                if vim.tbl_contains({ "AvanteInput", "AvantePromptInput" }, vim.bo.filetype) then
                    vim.keymap.set("i", "<C-a>", "<HOME>", { buffer = true })
                    vim.keymap.set("i", "<C-e>", "<END>", { buffer = true })
                else
                    vim.keymap.set("n", "i", insert_avante, { buffer = true })
                end
            end,
        })

        return {
            provider = "copilot",
            providers = {
                copilot = {
                    model = "claude-sonnet-4.5",
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
                    add_all_buffers = "<Leader>ab",
                },
            },
            windows = {
                input = {
                    height = 12,
                },
                ask = {
                    start_insert = false,
                },
            },
            file_selector = {
                provider = "telescope",
            },
            selector = {
                provider = "telescope",
            },
        }
    end,
}
