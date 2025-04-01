return {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
        { "<Leader>dv", ":DiffviewOpen<CR>", desc = "Open Diffview" },
    },
    opts = {
        keymaps = {
            view = {
                ["<Leader>b"] = false,
                ["<Leader>co"] = false,
                ["<Leader>ct"] = false,
                ["<Leader>cb"] = false,
                ["<Leader>ca"] = false,
                ["<Leader>cO"] = false,
                ["<Leader>cT"] = false,
                ["<Leader>cA"] = false,

                ["<Leader>w"] = function()
                    require("diffview.actions").toggle_files()
                end,

                ["<Leader>cJ"] = function()
                    require("diffview.actions").conflict_choose_all("theirs")()
                end,
                ["<Leader>cK"] = function()
                    require("diffview.actions").conflict_choose_all("ours")()
                end,
                ["<Leader>cN"] = function()
                    require("diffview.actions").conflict_choose_all("none")()
                end,
                ["<Leader>cB"] = function()
                    require("diffview.actions").conflict_choose_all("all")()
                end,
            },
        },
    },
}
