local M = {}
local api = vim.api
local fn = vim.fn

local SMART_QUIT_CONFIGS = {
    ["q"] = { is_write = false },
    ["wq"] = { is_write = true },
}

local function tabpage_list_buflisted_wins()
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

function M.smart_quit(cmd)
    local is_write = SMART_QUIT_CONFIGS[cmd].is_write

    if fn.getcmdtype() ~= ":" or fn.getcmdline() ~= cmd or #tabpage_list_buflisted_wins() ~= 0 then
        return cmd
    end

    cmd = #api.nvim_list_tabpages() > 1 and "tabclose" or "qa"

    return is_write and "w | " .. cmd or cmd
end

local WINDOW_KEYS = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" }
function M.block_window_keymaps(buf)
    for _, key in pairs(WINDOW_KEYS) do
        vim.keymap.set("n", key, "<Nop>", { buffer = buf })
    end
end

function M.redirect_win(opts)
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

function M.redirect_git_floatwin()
    local width = 120
    local height = math.floor(vim.go.lines * 0.9)
    local row = math.floor((vim.go.lines - height) / 2)
    local col = math.floor((vim.go.columns - width) / 2)

    local opts = {
        enter = true,
        win_config = {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            zindex = 45,
        },
    }
    local win = M.redirect_win(opts)
    vim.wo[win].winfixbuf = true
    return win
end

return M
