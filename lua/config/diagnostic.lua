local M = {}

---@return nil
function M.setup()
    vim.diagnostic.config({
        float = {
            border = "rounded",
            source = true,
        },
        virtual_text = {
            prefix = "●",
            source = true,
        },
    })
end

return M
