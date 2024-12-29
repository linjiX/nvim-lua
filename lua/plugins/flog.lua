return {
    "rbong/vim-flog",
    lazy = true,
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
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = { "tpope/vim-fugitive" },
    config = function()
        vim.g.flog_permanent_default_opts = { date = "short" }

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("FlogAutocmd", { clear = true }),
            pattern = "floggraph",
            callback = function()
                vim.wo.colorcolumn = "0"
            end,
        })
    end,
}
