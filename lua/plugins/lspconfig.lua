local function get_python_path()
    if vim.env.VIRTUAL_ENV then
        local path = require("lspconfig/util").path
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end

    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

local function get_vue_plugin_path()
    local mason = require("mason-registry")
    local package_path = mason.get_package("vue-language-server"):get_install_path()

    return package_path .. "/node_modules/@vue/language-server"
end

return {
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        lazy = false,
        keys = {
            { "[oj", vim.cmd.LspStart },
            { "]oj", vim.cmd.LspStop },
            { "yoJ", vim.cmd.LspRestart },
        },
        opts = {
            ensure_installed = { "lua_ls", "pyright" },
        },
        config = function()
            require("mason-lspconfig").setup_handlers({
                function(name)
                    require("lspconfig")[name].setup({})
                end,

                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        before_init = function(_, config)
                            config.settings.python.pythonPath = get_python_path()
                        end,
                    })
                end,

                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup({
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                workspace = {
                                    checkThirdParty = true,
                                    library = { vim.env.VIMRUNTIME },
                                    -- library = vim.api.nvim_get_runtime_file("", true),
                                },
                            },
                        },
                    })
                end,

                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        init_options = {
                            plugins = {
                                {
                                    name = "@vue/typescript-plugin",
                                    location = get_vue_plugin_path(),
                                    languages = { "vue" },
                                },
                            },
                        },
                        filetypes = { "typescript", "javascript", "vue" },
                    })
                end,
            })
        end,
    },
}
