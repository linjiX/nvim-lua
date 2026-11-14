local M = {}

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
            paths[path] = true
        end
    end

    return paths
end

--- The loaded files reach the servers through their buffers, the rest only through this
---@param paths string[]
function M.notify_changed(paths)
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

return M
