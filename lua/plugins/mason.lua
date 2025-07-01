return {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<Leader>m", ":Mason<CR>", silent = true, desc = "Open Mason" } },
    opts = {
        registries = {
            "github:mason-org/mason-registry",
            "lua:registry",
        },
        ui = { border = "rounded" },
    },
}
