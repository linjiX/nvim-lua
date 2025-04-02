local M = {}

local ignored_filetypes = { "gitcommit", "gitrebase" }

M.unloaded_buffers = {}

function M.add_unloaded_buffer(opts)
    local buf = opts.buf
    if
        vim.fn.buflisted(buf) == 0
        or vim.bo[buf].buftype ~= ""
        or vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
    then
        return
    end

    local filename = opts.match
    if not vim.fn.filereadable(filename) or vim.tbl_contains(M.unloaded_buffers, filename) then
        return
    end

    table.insert(M.unloaded_buffers, filename)
end

function M.reopen_buffer()
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

return M
