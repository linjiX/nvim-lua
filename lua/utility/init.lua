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
            return target(unpack(args))
        end

        return fn
    end,
}

local script_functions = {}

---@param scriptname string
---@return string|nil
local function get_script_snr(scriptname)
    local scriptnames = vim.api.nvim_exec2("scriptnames", { output = true }).output

    for _, line in ipairs(vim.split(scriptnames, "\n", { trimempty = true })) do
        if vim.endswith(line, scriptname) then
            return vim.trim(vim.split(line, ": ")[1])
        end
    end
    return nil
end

---@class LazyModule
---@field private name string
---@field private keys string[]
---@field [string] LazyModule
---@operator call(...): fun(): any

---@param name string
---@return LazyModule
function M.lazy_require(name)
    local result = { name = name, keys = {} }
    setmetatable(result, METATABLE)
    return result
end

---@param name string
---@param scriptname string
---@return function
function M.get_script_function(name, scriptname)
    if script_functions[name] then
        return script_functions[name]
    end

    local snr = get_script_snr(scriptname)
    if not snr then
        error(("Script not found '%s'"):format(scriptname))
    end

    local function_name = ("<SNR>%s_%s"):format(snr, name)
    if vim.fn.exists("*" .. function_name) == 1 then
        script_functions[name] = vim.fn[function_name]
        return script_functions[name]
    end

    error(("Function '%s' not found in script '%s'"):format(name, scriptname))
end

---@return nil
function M.tabopen()
    local view = vim.fn.winsaveview()
    vim.cmd.tabedit("%")
    vim.fn.winrestview(view)
end

---@param target string|nil
---@return boolean
function M.is_commit_id(target)
    return target and #target >= 7 and #target <= 40 and target:match("^[0-9a-f]+$")
end

return M
