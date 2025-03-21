local M = {}
local api = vim.api
local fn = vim.fn

local WINDOW_KEYS = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" }
M.block_window_keymaps = function(buf)
    for _, key in pairs(WINDOW_KEYS) do
        vim.keymap.set("n", key, "<Nop>", { buffer = buf })
    end
end

M.tabpage_list_buflisted_wins = function()
    local wins = {}
    local current_win = api.nvim_get_current_win()

    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        if win ~= current_win then
            local buf = api.nvim_win_get_buf(win)
            if vim.bo[buf].buflisted then
                table.insert(wins, win)
            end
        end
    end
    return wins
end

M.redirect_win = function(opts)
    local buf = api.nvim_get_current_buf()
    local source_win = api.nvim_get_current_win()

    local previous_win = fn.win_getid(fn.winnr("#"))
    api.nvim_set_current_win(previous_win)

    local win = api.nvim_open_win(buf, opts.enter, opts.win_config)
    api.nvim_win_close(source_win, false)

    if opts.win_config.relative then
        M.block_window_keymaps(buf)
    end

    return win
end

return M
