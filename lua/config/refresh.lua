local lsp_files = require("config.lsp_files")
local utility = require("config.utility")

local M = {}

local SETTLE_DELAY_MS = 150
local MAX_SETTLE_DELAY_MS = 1000
local GIT_STATUS_RELOAD_INTERVAL_MS = 1000

local FUGITIVE_CURRENT_WINDOW_ONLY = 0

--- The basenames of the git directory entries fugitive's status depends on
local WATCHED_GIT_FILES = {
    FETCH_HEAD = true,
    HEAD = true,
    ORIG_HEAD = true,
    index = true,
    ["packed-refs"] = true,
}

---@return table<integer, integer> the first window of every fugitive status buffer
local function get_fugitive_status_windows()
    ---@type table<integer, integer>
    local window_by_status_buf = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.b[buf].fugitive_type == "index" then
            window_by_status_buf[buf] = window_by_status_buf[buf] or win
        end
    end

    return window_by_status_buf
end

---@param buf integer
---@param win integer
local function reload_fugitive_buffer(buf, win)
    -- The repository may be gone by now
    pcall(vim.api.nvim_win_call, win, function()
        vim.fn["fugitive#DidChange"](buf, FUGITIVE_CURRENT_WINDOW_ONLY)
    end)
end

---@param matches fun(buf: integer): boolean
local function reload_fugitive_status_where(matches)
    for buf, win in pairs(get_fugitive_status_windows()) do
        if matches(buf) then
            reload_fugitive_buffer(buf, win)
        end
    end
end

--- A change behind Neovim's back fires none of the events fugitive refreshes on
---@param paths string[]
local function reload_fugitive_status(paths)
    reload_fugitive_status_where(function(buf)
        -- A symbolic link spells the worktree and the paths differently
        local worktree = vim.fn.resolve(vim.fn.FugitiveWorkTree(buf))

        return worktree ~= ""
            and vim.iter(paths):any(function(path)
                return vim.fs.relpath(worktree, vim.fn.resolve(path)) ~= nil
            end)
    end)
end

--- A `git` command touches the git directory only
---@param common_dirs table<string, boolean>
local function reload_fugitive_status_at(common_dirs)
    reload_fugitive_status_where(function(buf)
        return common_dirs[vim.fn.FugitiveCommonDir(buf)] or false
    end)
end

--- nvim-tree watches only the directories it has explored, so the rest keep a stale git
--- status even once they get expanded
local function reload_nvim_tree_git()
    local api = package.loaded["nvim-tree.api"]
    if api then
        api.tree.reload_git()
    end
end

--- `Snacks.util.throttle` drops the arguments, so the keys wait in the closure
---@param reload fun(keys: table<string, boolean>)
---@return fun(keys: string[])
local function throttle_by_keys(reload)
    ---@type table<string, boolean>
    local pending = {}

    local throttled = require("snacks").util.throttle(function()
        local keys = pending
        pending = {}

        reload(keys)
    end, { ms = GIT_STATUS_RELOAD_INTERVAL_MS })

    return function(keys)
        for _, key in ipairs(keys) do
            pending[key] = true
        end

        throttled()
    end
end

local schedule_git_status_reload = throttle_by_keys(function(paths)
    reload_fugitive_status(vim.tbl_keys(paths))
    reload_nvim_tree_git()
end)

local schedule_fugitive_reload = throttle_by_keys(reload_fugitive_status_at)

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
    lsp_files.notify_changed(paths)

    -- The git status views reload synchronously, so keep them out of this refresh
    schedule_git_status_reload(paths)
end)

--- Refreshes the buffers, the LSP clients and the git status views once the events settle
--- down. Stays fast event safe, so a `uv_fs_event_t` callback can call it.
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

---@type table<string, uv.uv_fs_event_t>
local git_watchers = {}

---@param filename string
---@return boolean
local function is_watched_git_file(filename)
    return WATCHED_GIT_FILES[filename] or false
end

--- A push that changed nothing leaves only the lock behind
---@param filename string
---@return boolean
local function is_ref_update(filename)
    return not vim.endswith(filename, ".lock")
end

---@param path string
---@param common_dir string
---@param is_watched fun(filename: string): boolean
---@param flags table? the `vim.uv.fs_event_start` flags
local function watch_git_path(path, common_dir, is_watched, flags)
    if git_watchers[path] then
        return
    end

    local watcher = vim.uv.new_fs_event()
    if not watcher then
        return
    end

    git_watchers[path] = watcher

    local ok = watcher:start(path, flags or {}, function(_, filename)
        -- Stays fast event safe, as a `uv_fs_event_t` callback
        if filename and is_watched(filename) then
            schedule_fugitive_reload({ common_dir })
        end
    end)

    if not ok then
        git_watchers[path] = nil
        watcher:close()
    end
end

--- Refreshes the fugitive status views after a `git` command Neovim never sees
---@param git_dir string
---@param common_dir string the git directory a linked worktree shares
function M.watch_git_dir(git_dir, common_dir)
    -- `vim.fs.joinpath` would turn an empty directory into a relative path
    if git_dir == "" or common_dir == "" then
        return
    end

    watch_git_path(git_dir, common_dir, is_watched_git_file)

    -- A linked worktree leaves the shared `packed-refs` in the common directory, which the
    -- call above registers in a plain repository, so both have to accept the same entries
    watch_git_path(common_dir, common_dir, is_watched_git_file)

    -- A `git push` writes the remote ref only, which a slash in its branch name nests
    local remotes = vim.fs.joinpath(common_dir, "refs", "remotes")
    watch_git_path(remotes, common_dir, is_ref_update, { recursive = true })
end

return M
