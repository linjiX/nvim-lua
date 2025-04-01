local M = {}

local METATABLE = {
    __index = function(self, key)
        table.insert(self.keys, key)
        return self
    end,
    __call = function(self, ...)
        local target = nil
        local args = { ... }

        local fn = function()
            if target == nil then
                target = require(self.name)
                for _, key in ipairs(self.keys) do
                    target = target[key]
                end
            end
            target(unpack(args))
        end

        return fn
    end,
}

local script_functions = {}

local function get_script_snr(scriptname)
    local scriptnames = vim.api.nvim_exec2("scriptnames", { output = true }).output

    for _, line in ipairs(vim.split(scriptnames, "\n", { trimempty = true })) do
        if vim.endswith(line, scriptname) then
            return vim.trim(vim.split(line, ": ")[1])
        end
    end
    return nil
end

function M.lazy_require(name)
    local result = { name = name, keys = {} }
    setmetatable(result, METATABLE)
    return result
end

function M.get_script_function(name, scriptname)
    if script_functions[name] then
        return script_functions[name]
    end

    local snr = get_script_snr(scriptname)
    if not snr then
        return nil
    end

    local function_name = ("<SNR>%s_%s"):format(snr, name)
    if vim.fn.exists("*" .. function_name) == 1 then
        script_functions[name] = vim.fn[function_name]
        return script_functions[name]
    end

    return nil
end

function M.tabopen()
    local view = vim.fn.winsaveview()
    vim.cmd.tabedit("%")
    vim.fn.winrestview(view)
end

return M
