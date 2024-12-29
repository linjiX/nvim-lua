return {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
        { "<Leader>dv", ":DiffviewOpen<CR>", desc = "Open Diffview" },
    },
    opts = {
        keymaps = {
            view = {
                ["<leader>b"] = false,
                ["<leader>co"] = false,
                ["<leader>ct"] = false,
                ["<leader>cb"] = false,
                ["<leader>ca"] = false,
                ["<leader>cO"] = false,
                ["<leader>cT"] = false,
                ["<leader>cA"] = false,

                ["<leader>w"] = function()
                    require("diffview.actions").toggle_files()
                end,

                ["<leader>cJ"] = function()
                    require("diffview.actions").conflict_choose_all("theirs")()
                end,
                ["<leader>cK"] = function()
                    require("diffview.actions").conflict_choose_all("ours")()
                end,
                ["<leader>cN"] = function()
                    require("diffview.actions").conflict_choose_all("none")()
                end,
                ["<leader>cB"] = function()
                    require("diffview.actions").conflict_choose_all("all")()
                end,
            },
        },
    },
}
