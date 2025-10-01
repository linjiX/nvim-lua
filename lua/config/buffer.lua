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

---@return nil
function M.setup()
    vim.keymap.set("n", "<Leader>u", reopen_buffer)

    local augroup = vim.api.nvim_create_augroup("MyBuffer", { clear = true })

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
