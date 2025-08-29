local M = {}

local METATABLE = {
    __index = function(self, key)
        local other = vim.deepcopy(self)
        table.insert(other.keys, key)
        return other
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
            return target(unpack(vim.deepcopy(args)))
        end

        return fn
    end,
}

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

---@return string
function M.get_python_path()
    if vim.env.VIRTUAL_ENV then
        return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
    end

    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

---@param bufnr number|nil
---@return string|nil
function M.get_terminal_command(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local pid = vim.b[bufnr].terminal_job_pid
    if not pid then
        error("Failed to get terminal job pid")
    end

    local tty = vim.fn.system("ps -o tty= " .. pid)
    if vim.v.shell_error ~= 0 then
        error("Failed to get terminal tty")
    end

    local ps_result = vim.fn.system("ps -o stat= -o command= -t " .. vim.trim(tty))
    if vim.v.shell_error ~= 0 then
        error("Failed to get process list")
    end

    local ps_lines = vim.split(ps_result, "\n", { trimempty = true })
    local fg_command_parts = nil

    for i = #ps_lines, 1, -1 do
        local line = ps_lines[i]

        local parts = vim.split(line, "%s+", { trimempty = true })

        if #parts > 0 and parts[1]:find("+") then
            fg_command_parts = { unpack(parts, 2) }

            if fg_command_parts[1] == "fzf" then
                break
            end
        end
    end

    if not fg_command_parts then
        error("Fail to get terminal foreground process")
    end

    local fg_command = vim.fn.fnamemodify(fg_command_parts[1], ":t")

    if fg_command:match("^[Pp]ython") and fg_command_parts[2] then
        fg_command = vim.fn.fnamemodify(fg_command_parts[2], ":t")
    end

    return fg_command
end

return M
