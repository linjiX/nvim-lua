local M = {}

local STAR_CONFIGS = {
    ["*"] = { is_g = false, searchforward = true },
    ["g*"] = { is_g = true, searchforward = true },
    ["#"] = { is_g = false, searchforward = false },
    ["g#"] = { is_g = true, searchforward = false },
}

---@param pattern string
---@param searchforward boolean
---@return nil
local function do_search(pattern, searchforward)
    vim.fn.setreg("/", pattern)
    vim.fn.histadd("search", pattern)
    vim.v.searchforward = searchforward
    vim.v.hlsearch = true
end

---@param count integer
---@return nil
local function do_count(count)
    if count ~= 0 then
        vim.cmd.normal({ count .. "n", bang = true })
    end
end

---@param key "*"|"#"
---@return nil
function M.visual_star(key)
    local mode = vim.fn.mode()
    local count = vim.v.count

    vim.cmd.normal(vim.keycode("<ESC>"))

    local start = vim.fn.getpos("'<")
    local stop = vim.fn.getpos("'>")

    local region = vim.fn.getregion(start, stop, { type = mode })

    local lines = vim.tbl_map(function(line)
        return vim.fn.escape(line, [[\]])
    end, region)

    local pattern = [[\V]] .. table.concat(lines, [[\n]])

    local config = STAR_CONFIGS[key]
    do_search(pattern, config.searchforward)

    vim.fn.setpos(".", start)
    do_count(count)
end

---@param key "*"|"g*"|"#"|"g#"
---@return nil
function M.star(key)
    local config = STAR_CONFIGS[key]

    local word = vim.fn.expand("<cword>")
    if #word == 0 then
        vim.notify("No string under cursor", vim.log.levels.ERROR)
        return
    end

    local is_g = (config.is_g or (vim.fn.match(word, [[\k]]) == -1))
    local pattern = is_g and word or ([[\<%s\>]]):format(word)

    do_search(pattern, config.searchforward)

    local lnum, col = unpack(vim.fn.searchpos(pattern, "cen"))
    vim.api.nvim_win_set_cursor(0, { lnum, col - word:len() })
    do_count(vim.v.count)
end

return M
