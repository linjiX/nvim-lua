return {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = {
        { "<Leader>m", vim.cmd.Mason, desc = "Open Mason" },
    },
    opts = {
        registries = {
            "github:mason-org/mason-registry",
            "lua:registry",
        },
        pip = {
            upgrade_pip = true,
        },
        ui = { border = "rounded" },
    },
}
