local M = {}
local api = vim.api
local fn = vim.fn

local utility = require("config.utility")

local SMART_QUIT_CONFIGS = {
    ["q"] = { is_write = false },
    ["wq"] = { is_write = true },
}

---@return integer[]
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

---@param cmd 'q'|'wq'
---@return string
function M.smart_quit(cmd)
    local is_write = SMART_QUIT_CONFIGS[cmd].is_write

    if fn.getcmdtype() ~= ":" or fn.getcmdline() ~= cmd or #tabpage_list_buflisted_wins() ~= 0 then
        return cmd
    end

    local quit_cmd = #api.nvim_list_tabpages() > 1 and "tabclose" or "qa"

    return is_write and "w | " .. quit_cmd or quit_cmd
end

local NAVIGATION_KEYS = { "h", "j", "k", "l" }
local NAVIGATION_VERTICAL_KEYS = { "j", "k" }
local QUIT_KEYS = { "q", "<Leader>q" }

--- @param wincmd fun(key: string): nil
--- @return { [1]: string, [2]: (fun(): nil), mode: string|string[] }[]
function M.get_navigation_lazy_keys(wincmd)
    local keys = {}
    for _, key in ipairs(NAVIGATION_KEYS) do
        table.insert(keys, {
            ("<C-%s>"):format(key),
            function()
                wincmd(key)
            end,
            mode = vim.tbl_contains(NAVIGATION_VERTICAL_KEYS, key) and "n" or { "n", "t" },
        })
    end

    for _, key in ipairs(NAVIGATION_VERTICAL_KEYS) do
        local lhs = ("<C-%s>"):format(key)

        table.insert(keys, {
            lhs,
            function()
                if utility.get_terminal_command() == "fzf" then
                    vim.api.nvim_chan_send(vim.b.terminal_job_id, vim.keycode(lhs))
                    return
                end
                wincmd(key)
            end,
            mode = "t",
        })
    end

    return keys
end

---@return nil
function M.set_navigation_keymaps()
    local keys = M.get_navigation_lazy_keys(vim.cmd.wincmd)
    for _, keymap in ipairs(keys) do
        vim.keymap.set(keymap.mode, keymap[1], keymap[2])
    end
end

---@param buf integer
---@return nil
function M.block_navigation_keymaps(buf)
    for _, key in pairs(NAVIGATION_KEYS) do
        vim.keymap.set("n", ("<C-%s>"):format(key), "<Nop>", { buffer = buf })
    end
end

---@param rhs? function|string
---@param opts? vim.keymap.set.Opts
---@param check? boolean
---@return nil
function M.set_quit_keymaps(rhs, opts, check)
    rhs = rhs or function()
        vim.cmd(M.smart_quit("q"))
    end

    opts = opts and vim.deepcopy(opts) or {}
    opts.buffer = true
    if not opts.desc then
        opts.desc = "Quit"
    end

    local keys = QUIT_KEYS
    if check then
        local existing_keys = {}
        for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
            existing_keys[keymap.lhsraw] = true
        end

        keys = vim.tbl_filter(function(key)
            return not existing_keys[vim.keycode(key)]
        end, keys)
    end

    for _, key in ipairs(keys) do
        vim.keymap.set("n", key, rhs, opts)
    end
end

---@param opts { enter: boolean, win_config: vim.api.keyset.win_config }
---@return integer|nil
function M.redirect_win(opts)
    local buf = api.nvim_get_current_buf()
    local source_win = api.nvim_get_current_win()

    if vim.api.nvim_win_get_config(source_win).relative ~= "" then
        return nil
    end

    local previous_winnr = fn.winnr("#")
    if previous_winnr == 0 then
        return nil
    end

    local previous_win = fn.win_getid(previous_winnr)
    api.nvim_set_current_win(previous_win)

    local win = api.nvim_open_win(buf, opts.enter, opts.win_config)
    api.nvim_win_close(source_win, false)

    if opts.win_config.relative then
        M.block_navigation_keymaps(buf)
    end

    return win
end

---@return integer|nil
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
    if not win then
        return nil
    end
    vim.wo[win].winfixbuf = true
    return win
end

---@return integer|nil
function M.setup()
    M.set_navigation_keymaps()

    for _, cmd in ipairs(vim.tbl_keys(SMART_QUIT_CONFIGS)) do
        vim.keymap.set("ca", cmd, function()
            return M.smart_quit(cmd)
        end, { expr = true })
    end
end

return M
