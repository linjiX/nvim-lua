local M = {}

--- How young a file has to be to count as created rather than changed
local CREATED_WINDOW_SEC = 5

local FileChangeType = vim.lsp.protocol.FileChangeType

--- Neovim watches the files only where it advertises the support (macOS and Windows), so
--- the servers it leaves out need the notification
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
            paths[vim.fn.resolve(path)] = true
        end
    end

    return paths
end

---@param client vim.lsp.Client
---@return string[]
local function get_workspace_dirs(client)
    return vim.tbl_map(function(folder)
        return vim.fn.resolve(vim.uri_to_fname(folder.uri))
    end, client.workspace_folders or {})
end

---@param dirs string[]
---@param path string
---@return boolean
local function is_below(dirs, path)
    return vim.iter(dirs):any(function(dir)
        return vim.fs.relpath(dir, path) ~= nil
    end)
end

--- Neovim calls a renamed file created, which a fresh birth time stands in for here
---@param stat uv.fs_stat.result
---@return lsp.FileChangeType
local function get_file_change_type(stat)
    local created = os.time() - stat.birthtime.sec <= CREATED_WINDOW_SEC
    return created and FileChangeType.Created or FileChangeType.Changed
end

--- The loaded files reach the servers through their buffers, the rest only through this
---@param paths string[]
function M.notify_changed(paths)
    local method = vim.lsp.protocol.Methods.workspace_didChangeWatchedFiles

    local loaded = get_loaded_file_paths()

    ---@type { path: string, event: lsp.FileEvent }[]
    local changes = {}
    for _, path in ipairs(paths) do
        -- A symbolic link spells the same file differently, so compare what resolves and,
        -- like Neovim's own watcher, send the spelling the event gave us
        local resolved = vim.fn.resolve(path)
        local stat = vim.uv.fs_stat(path)

        -- The file system events also report directories
        if not loaded[resolved] and not (stat and stat.type == "directory") then
            table.insert(changes, {
                path = resolved,
                event = {
                    uri = vim.uri_from_fname(path),
                    type = stat and get_file_change_type(stat) or FileChangeType.Deleted,
                },
            })
        end
    end

    if #changes == 0 then
        return
    end

    for _, client in ipairs(vim.lsp.get_clients()) do
        if not is_watched_by_nvim(client, method) then
            -- A server has no use for a file outside the directories it was given
            local dirs = get_workspace_dirs(client)
            local events = vim.iter(changes)
                :filter(function(change)
                    return is_below(dirs, change.path)
                end)
                :map(function(change)
                    return change.event
                end)
                :totable()

            if #events > 0 then
                client:notify(method, { changes = events })
            end
        end
    end
end

return M
