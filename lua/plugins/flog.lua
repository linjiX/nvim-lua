return {
    "rbong/vim-flog",
    dependencies = { "tpope/vim-fugitive" },
    cmd = { "Flog", "Flogsplit", "Floggit" },
    keys = {
        {
            "gb",
            function()
                local flog = require("flog")
                local cmd = flog.format("GBrowse %h")
                flog.exec(cmd)
            end,
            ft = "floggraph",
            desc = "Git Browse",
        },
    },
    config = function()
        vim.g.flog_permanent_default_opts = { date = "short" }
    end,
}
