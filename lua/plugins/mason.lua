return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>m", ":Mason<CR>", silent = true, desc = "Open Mason" } },
    opts = {
        registries = {
            "github:mason-org/mason-registry",
            "lua:registry",
        },
        ui = { border = "rounded" },
    },
}
