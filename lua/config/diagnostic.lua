local M = {}

M.icons = {
    error = " ",
    warn = " ",
    info = " ",
    hint = " ",
}

---@param severity vim.diagnostic.Severity
local function map_diagnostic_pairs(severity)
    ---@cast severity string
    local name = severity:lower()
    local key = name:sub(1, 1)

    vim.keymap.set("n", "]g" .. key, function()
        vim.diagnostic.jump({ count = vim.v.count1, severity = severity })
    end, { desc = "Next " .. name })

    vim.keymap.set("n", "[g" .. key, function()
        vim.diagnostic.jump({ count = -vim.v.count1, severity = severity })
    end, { desc = "Prev " .. name })

    vim.keymap.set("n", "]g" .. key:upper(), function()
        vim.diagnostic.jump({ count = math.huge, wrap = false, severity = severity })
    end, { desc = "First " .. name })

    vim.keymap.set("n", "[g" .. key:upper(), function()
        vim.diagnostic.jump({ count = -math.huge, wrap = false, severity = severity })
    end, { desc = "Last " .. name })
end

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
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = M.icons.error,
                [vim.diagnostic.severity.WARN] = M.icons.warn,
                [vim.diagnostic.severity.HINT] = M.icons.hint,
                [vim.diagnostic.severity.INFO] = M.icons.info,
            },
        },
    })

    for _, severity in ipairs(vim.diagnostic.severity) do
        map_diagnostic_pairs(severity)
    end
end

return M
