local utility = require("config.utility")

local M = {}

local SETTLE_DELAY_MS = 150
local MAX_SETTLE_DELAY_MS = 1000
local GIT_STATUS_RELOAD_INTERVAL_MS = 1000

local FUGITIVE_CURRENT_WINDOW_ONLY = 0

--- Neovim watches the files itself only where it advertises the support (macOS and Windows),
--- so the servers it leaves out need the notification
---@param client vim.lsp.Client
---@param method string
---@return boolean
local function is_watched_by_nvim(client, method)
    local dynamic_registration = vim.tbl_get(
        client.capabilities,
        "workspace",
        "didChangeWatchedFiles",
        "dynamicRegistration"
    )
    -- Dynamic registration only, so `supports_method` stays false until the server registers
    return dynamic_registration and client:supports_method(method) or false
end

---@return table<string, boolean>
local function get_loaded_file_paths()
    local paths = {}

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local path = vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf)

        if path and path ~= "" then
            paths[path] = true
        end
    end

    return paths
end

--- The loaded files reach the servers through their buffers, the rest only through this
---@param paths string[]
local function notify_lsp_files_changed(paths)
    local method = vim.lsp.protocol.Methods.workspace_didChangeWatchedFiles
    local FileChangeType = vim.lsp.protocol.FileChangeType

    local loaded = get_loaded_file_paths()

    ---@type lsp.FileEvent[]
    local events = {}
    for _, path in ipairs(paths) do
        local stat = vim.uv.fs_stat(path)
        -- The file system events also report directories
        if not loaded[path] and not (stat and stat.type == "directory") then
            table.insert(events, {
                uri = vim.uri_from_fname(path),
                type = stat and FileChangeType.Changed or FileChangeType.Deleted,
            })
        end
    end

    if #events == 0 then
        return
    end

    for _, client in ipairs(vim.lsp.get_clients()) do
        if not is_watched_by_nvim(client, method) then
            client:notify(method, { changes = events })
        end
    end
end

--- A change behind Neovim's back triggers none of the events fugitive refreshes its status on
---@param paths string[]
local function reload_fugitive_status(paths)
    ---@type table<integer, integer>
    local window_by_status_buf = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.b[buf].fugitive_type == "index" then
            window_by_status_buf[buf] = window_by_status_buf[buf] or win
        end
    end

    if vim.tbl_isempty(window_by_status_buf) then
        return
    end

    paths = vim.tbl_map(vim.fn.resolve, paths)

    for buf, win in pairs(window_by_status_buf) do
        local worktree = vim.fn.resolve(vim.fn.FugitiveWorkTree(buf))
        local has_changes = worktree ~= ""
            and vim.iter(paths):any(function(path)
                return vim.fs.relpath(worktree, path) ~= nil
            end)

        if has_changes then
            -- The repository may be gone by now
            pcall(vim.api.nvim_win_call, win, function()
                vim.fn["fugitive#DidChange"](buf, FUGITIVE_CURRENT_WINDOW_ONLY)
            end)
        end
    end
end

--- The watchers nvim-tree runs cover the directories it has explored, and a change below the
--- rest leaves their git status stale even after they get expanded
local function reload_nvim_tree_git()
    local api = package.loaded["nvim-tree.api"]
    if api then
        api.tree.reload_git()
    end
end

--- `Snacks.util.throttle` drops the arguments, so the paths wait in the closure instead
local schedule_git_status_reload
do
    ---@type table<string, boolean>
    local changed_paths = {}

    local reload = require("snacks").util.throttle(function()
        local paths = vim.tbl_keys(changed_paths)
        changed_paths = {}

        reload_fugitive_status(paths)
        reload_nvim_tree_git()
    end, { ms = GIT_STATUS_RELOAD_INTERVAL_MS })

    ---@param paths string[]
    function schedule_git_status_reload(paths)
        for _, path in ipairs(paths) do
            changed_paths[path] = true
        end

        reload()
    end
end

local timer = assert(vim.uv.new_timer())

---@type table<string, boolean>
local changed_paths = {}
---@type integer?
local settle_deadline = nil

local flush = vim.schedule_wrap(function()
    local paths = vim.tbl_keys(changed_paths)
    changed_paths = {}
    settle_deadline = nil

    -- A `:checktime` from a file watcher reloads nothing while a terminal keeps the focus
    utility.reload_buffers()
    notify_lsp_files_changed(paths)

    -- The git status views reload synchronously, so keep them out of this refresh
    schedule_git_status_reload(paths)
end)

--- Refreshes the buffers, the LSP clients and the git status views once the file system
--- events settle down. Stays fast event safe, so a `uv_fs_event_t` callback can call it.
---@param paths string[]
function M.schedule(paths)
    for _, path in ipairs(paths) do
        changed_paths[path] = true
    end

    -- A tool that keeps writing would defer the refresh forever, so cap the wait
    local now = vim.uv.now()
    settle_deadline = settle_deadline or now + MAX_SETTLE_DELAY_MS

    -- A negative timeout wraps around in libuv, which never fires
    local remaining = math.max(settle_deadline - now, 0)

    timer:start(math.min(SETTLE_DELAY_MS, remaining), 0, flush)
end

return M
