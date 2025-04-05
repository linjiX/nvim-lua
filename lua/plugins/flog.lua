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
        { "q", "<Plug>(FlogQuit)", ft = "floggraph", desc = "Quit Flog" },
        { "<Leader>q", "<Plug>(FlogQuit)", ft = "floggraph", desc = "Quit Flog" },
    },
    config = function()
        vim.g.flog_permanent_default_opts = { date = "short" }
    end,
}
