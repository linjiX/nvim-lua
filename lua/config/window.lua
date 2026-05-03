local M = {}
local api = vim.api
local fn = vim.fn

local utility = require("config.utility")

local SMART_QUIT_CONFIGS = {
    ["q"] = { is_write = false },
    ["wq"] = { is_write = true },
}

---@class CursorLineBindState
---@field autocmd integer
---@field curswant integer
---@field lnum integer

---@class CursorLineBind
---@field active boolean
---@field group integer
---@field states table<integer, CursorLineBindState>

---@type CursorLineBind
local CURSORLINE_BIND = {
    active = false,
    group = api.nvim_create_augroup("MyCursorLineBind", {}),
    states = {},
}

---@return integer[]
local function tabpage_list_other_wins()
    local wins = {}
    local current_win = api.nvim_get_current_win()

    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        if win ~= current_win then
            table.insert(wins, win)
        end
    end
    return wins
end

---@return integer[]
local function tabpage_list_buflisted_wins()
    local wins = {}

    for _, win in ipairs(tabpage_list_other_wins()) do
        local buf = api.nvim_win_get_buf(win)
        if vim.bo[buf].buflisted then
            table.insert(wins, win)
        end
    end
    return wins
end

---@return integer | nil
function M.tabpage_get_scrollbind_win()
    for _, win in ipairs(tabpage_list_other_wins()) do
        if vim.wo[win].scrollbind then
            return win
        end
    end
end

---@param win integer
---@return nil
local function sync_cursorline(win)
    local state = CURSORLINE_BIND.states[win]
    if not state then
        return
    end

    local view = fn.winsaveview()
    state.curswant = view.curswant

    if state.lnum == view.lnum then
        return
    end

    state.lnum = view.lnum

    local target_win = M.tabpage_get_scrollbind_win()
    if not target_win then
        return
    end

    local target_state = CURSORLINE_BIND.states[target_win]
    if not target_state then
        return
    end

    api.nvim_win_call(target_win, function()
        fn.winrestview({
            lnum = view.lnum,
            col = target_state.curswant,
            curswant = target_state.curswant,
        })
        target_state.lnum = api.nvim_win_get_cursor(target_win)[1]
    end)
end

---@param win integer
---@return nil
local function clear_cursorline_bind(win)
    local state = CURSORLINE_BIND.states[win]
    if state then
        CURSORLINE_BIND.states[win] = nil
        api.nvim_del_autocmd(state.autocmd)
    end
end

---@param win? integer
---@return nil
function M.bind_cursorline(win)
    win = win or api.nvim_get_current_win()

    clear_cursorline_bind(win)

    local buf = api.nvim_win_get_buf(win)
    vim.wo[win].cursorbind = false

    local autocmd = api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = CURSORLINE_BIND.group,
        buffer = buf,
        callback = function()
            if
                CURSORLINE_BIND.active
                or not api.nvim_win_is_valid(win)
                or api.nvim_get_current_win() ~= win
            then
                return
            end

            CURSORLINE_BIND.active = true

            pcall(sync_cursorline, win)

            CURSORLINE_BIND.active = false
        end,
    })

    local view = api.nvim_win_call(win, fn.winsaveview)
    CURSORLINE_BIND.states[win] = {
        autocmd = autocmd,
        curswant = view.curswant,
        lnum = view.lnum,
    }

    api.nvim_create_autocmd("WinClosed", {
        group = CURSORLINE_BIND.group,
        pattern = tostring(win),
        once = true,
        callback = function()
            clear_cursorline_bind(win)
        end,
    })
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

    local keymap_opts = vim.tbl_extend("force", opts or {}, {
        buffer = true,
        desc = opts and opts.desc or "Quit",
    })

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
        vim.keymap.set("n", key, rhs, keymap_opts)
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
