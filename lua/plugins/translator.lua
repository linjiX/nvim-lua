return {
    "voldikss/vim-translator",
    keys = {
        {
            "<Leader>T",
            ":TranslateW<CR>",
            mode = { "n", "x" },
            silent = true,
            desc = "Translate",
        },
    },
    config = function()
        vim.g.translator_window_borderchars =
            { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

        vim.api.nvim_set_hl(0, "Translator", { link = "NormalFloat", default = true })
        vim.api.nvim_set_hl(0, "TranslatorBorder", { link = "FloatBorder", default = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("MyTranslator", { clear = true }),
            pattern = { "translator", "translatorborder" },
            callback = function(opts)
                vim.schedule(function()
                    for _, win in ipairs(vim.fn.win_findbuf(opts.buf)) do
                        local config = vim.api.nvim_win_get_config(win)
                        if config.relative ~= "" then
                            vim.api.nvim_win_set_config(win, { border = "none" })
                        end
                    end
                end)
            end,
        })

        vim.keymap.set("n", "<C-u>", function()
            if vim.fn["translator#window#float#has_scroll"]() ~= 0 then
                return vim.fn["translator#window#float#scroll"](1)
            end
            return "<C-u>"
        end, { expr = true })
        vim.keymap.set("n", "<C-d>", function()
            if vim.fn["translator#window#float#has_scroll"]() ~= 0 then
                return vim.fn["translator#window#float#scroll"](0)
            end
            return "<C-d>"
        end, { expr = true })
    end,
}
