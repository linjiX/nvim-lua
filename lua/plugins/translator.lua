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

        vim.keymap.set("n", "<C-u>", function()
            if vim.fn["translator#window#float#has_scroll"]() ~= 0 then
                return vim.fn["translator#window#float#scroll"](1)
            end
            vim.api.nvim_feedkeys(vim.keycode("<C-u>"), "n", true)
        end)
        vim.keymap.set("n", "<C-d>", function()
            if vim.fn["translator#window#float#has_scroll"]() ~= 0 then
                return vim.fn["translator#window#float#scroll"](0)
            end
            vim.api.nvim_feedkeys(vim.keycode("<C-d>"), "n", true)
        end)
    end,
}
