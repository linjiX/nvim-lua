return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>m", ":Mason<CR>", silent = true, desc = "Open Mason" } },
    opts = {
        ui = { border = "rounded" },
    },
}
