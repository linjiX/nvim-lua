return {
    "hedyhli/outline.nvim",
    cmd = { "Outline" },
    opts = {
        preview_window = {
            border = "rounded",
        },
        keymaps = {
            close = "q",
            fold_toggle = "za",
        },
        -- providers = {
        --     lsp = {
        --         blacklist_clients = { "ts_ls" },
        --     },
        -- },
        symbols = {
            filter = {
                "String",
                "Boolean",
                "Number",
                "Array",
                "Object",
                "Variable",
                exclude = true,
            },
        },
    },
}
