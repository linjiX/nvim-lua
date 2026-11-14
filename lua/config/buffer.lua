local M = {}

local ignored_filetypes = { "gitcommit", "gitrebase" }

M.unloaded_buffers = {}

---@param t table
---@param value any
---@return integer|nil
local function tbl_find_index(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

---@param opts {buf: integer, match: string}
---@return nil
local function add_unloaded_buffer(opts)
    local buf = opts.buf
    if
        vim.fn.buflisted(buf) == 0
        or vim.bo[buf].buftype ~= ""
        or vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
    then
        return
    end

    local filename = opts.match
    if vim.fn.filereadable(filename) == 0 then
        return
    end

    local index = tbl_find_index(M.unloaded_buffers, filename)
    if index then
        table.remove(M.unloaded_buffers, index)
    end

    table.insert(M.unloaded_buffers, filename)
end

---@return nil
local function reopen_buffer()
    while #M.unloaded_buffers > 0 do
        local filename = M.unloaded_buffers[#M.unloaded_buffers]

        if vim.fn.buflisted(filename) == 0 then
            vim.cmd.edit(filename)
            table.remove(M.unloaded_buffers)
            return
        end

        table.remove(M.unloaded_buffers)
    end
    vim.notify("No unloaded buffers")
end

---@param args vim.api.keyset.create_autocmd.callback_args
---@return nil
local function wipe_empty_buffer(args)
    local buf = args.buf

    if
        args.file == ""
        and vim.bo[buf].buftype == ""
        and vim.bo[buf].filetype == ""
        and vim.bo[buf].bufhidden == ""
        and vim.api.nvim_buf_line_count(buf) == 1
        and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
    then
        vim.bo[buf].bufhidden = "wipe"

        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.bo[buf].bufhidden = ""
            end
        end)
    end
end

--- `<C-o>` and `<C-i>` stop at every jump, most of which stay in the same file
---@param backward boolean
---@return nil
local function jump_to_other_buffer(backward)
    -- A sidebar pins its buffer, and its jump list came from the window it was split from
    if vim.bo.buftype ~= "" or vim.wo.winfixbuf then
        return
    end

    local jumps, current = unpack(vim.fn.getjumplist())
    local buf = vim.api.nvim_get_current_buf()
    local step = backward and -1 or 1
    local remaining = vim.v.count1

    -- `getjumplist` numbers the entries from zero, and the current position sits past the end
    local index = current + 1
    local jump_count = 0

    for count = 1, #jumps do
        index = index + step
        if index < 1 or index > #jumps then
            break
        end

        if jumps[index].bufnr ~= buf then
            -- A count asks for that many files, and the list may run out before then
            buf = jumps[index].bufnr
            jump_count = count
            remaining = remaining - 1

            if remaining == 0 then
                break
            end
        end
    end

    if jump_count == 0 then
        vim.notify(("No %s file in the jump list"):format(backward and "older" or "newer"))
        return
    end

    vim.cmd.normal({ jump_count .. vim.keycode(backward and "<C-o>" or "<C-i>"), bang = true })
end

---@return nil
function M.setup()
    vim.keymap.set("n", "<Leader>o", function()
        jump_to_other_buffer(true)
    end, { desc = "Previous File" })

    vim.keymap.set("n", "<Leader>i", function()
        jump_to_other_buffer(false)
    end, { desc = "Next File" })

    vim.keymap.set("n", "<Leader>u", reopen_buffer)

    local augroup = vim.api.nvim_create_augroup("MyBuffer", { clear = true })

    -- The shada file restores the jump list into every window open at startup
    vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                vim.api.nvim_win_call(win, vim.cmd.clearjumps)
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
        group = augroup,
        pattern = "*",
        callback = add_unloaded_buffer,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        pattern = "*",
        callback = wipe_empty_buffer,
    })
end

return M
