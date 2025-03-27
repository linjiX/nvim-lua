local M = {}

local opts = {
    ["*"] = { is_g = false, searchforward = true },
    ["g*"] = { is_g = true, searchforward = true },
    ["#"] = { is_g = false, searchforward = false },
    ["g#"] = { is_g = true, searchforward = false },
}

local ESC = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

local function do_search(pattern, searchforward)
    vim.fn.setreg("/", pattern)
    vim.fn.histadd("search", pattern)
    vim.v.searchforward = searchforward
    vim.v.hlsearch = true
end

local function do_count(count)
    if count ~= 0 then
        vim.cmd.normal({ count .. "n", bang = true })
    end
end

M.visual_star = function(key)
    local mode = vim.fn.mode()
    local count = vim.v.count

    vim.cmd.normal(ESC)

    local start = vim.fn.getpos("'<")
    local stop = vim.fn.getpos("'>")

    local region = vim.fn.getregion(start, stop, { type = mode })

    local lines = vim.tbl_map(function(line)
        return vim.fn.escape(line, [[\]])
    end, region)

    local pattern = [[\V]] .. table.concat(lines, [[\n]])

    local opt = opts[key]
    do_search(pattern, opt.searchforward)

    vim.fn.setpos(".", start)
    do_count(count)
end

M.star = function(key)
    local opt = opts[key]

    local word = vim.fn.expand("<cword>")
    local pattern = opt.is_g and word or ([[\<%s\>]]):format(word)

    do_search(pattern, opt.searchforward)

    local lnum, col = unpack(vim.fn.searchpos(pattern, "cen"))
    vim.api.nvim_win_set_cursor(0, { lnum, col - word:len() })
    do_count(vim.v.count)
end

return M
