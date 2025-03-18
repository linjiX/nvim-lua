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

return {
    lazy_require = function(name)
        local result = { name = name, keys = {} }
        setmetatable(result, METATABLE)
        return result
    end,

    tabopen = function()
        local view = vim.fn.winsaveview()
        vim.cmd.tabedit("%")
        vim.fn.winrestview(view)
    end,
}
