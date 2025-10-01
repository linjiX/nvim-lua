local M = {}

---@param find_file boolean | nil
---@return nil
local function open_internal(find_file)
    M.close()
    local source_win = vim.api.nvim_get_current_win()

    require("nvim-tree.api").tree.open({ find_file = find_file })

    local target_win = vim.api.nvim_open_win(0, false, { split = "below" })

    require("aerial").open_in_win(target_win, source_win)

    if not find_file then
        vim.api.nvim_set_current_win(source_win)
    end
end

---@return boolean
function M.is_open()
    return require("aerial").is_open() and require("nvim-tree.api").tree.is_visible()
end

---@return nil
function M.open()
    if M.is_open() then
        return
    end

    open_internal()
end

---@return nil
function M.close()
    require("aerial").close()
    require("nvim-tree.api").tree.close()
end

---@return nil
function M.toggle()
    if M.is_open() then
        M.close()
    else
        open_internal()
    end
end

---@return nil
function M.find_file()
    local tree = require("nvim-tree.api").tree

    if tree.is_visible() then
        tree.open({ find_file = true })
        return
    end
    open_internal(true)
end

return M
