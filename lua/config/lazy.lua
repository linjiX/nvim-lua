local M = {}

-- lazy.nvim setup functin is basically copied from https://lazy.folke.io/installation
---@return nil
function M.setup()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    ---@diagnostic disable: undefined-field
    if not vim.uv.fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            lazyrepo,
            lazypath,
        })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)

    local lazy = require("lazy")

    lazy.setup({
        spec = {
            { import = "plugins" },
        },
        install = { colorscheme = { "tokyonight-night" } },
        checker = { enabled = true },
        ui = { border = "rounded" },
    })

    vim.keymap.set("n", "<Leader>ll", lazy.home, { desc = "Open Lazy" })
    vim.keymap.set("n", "<Leader>lu", lazy.update, { desc = "Lazy Update" })
end

return M
