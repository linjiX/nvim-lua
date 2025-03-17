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
    "neovim/nvim-lspconfig",
    lazy = false,
    keys = {
        { "[oj", vim.cmd.LspStart },
        { "]oj", vim.cmd.LspStop },
        { "yoJ", vim.cmd.LspRestart },
    },
    config = function()
        local opts = {
            lua_ls = {
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
            },
            vimls = {},
            jsonls = {},
            taplo = {},

            pyright = {
                before_init = function(_, config)
                    config.settings.python.pythonPath = get_python_path()
                end,
            },
            ruff = {},

            ts_ls = {
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
            },
            volar = {},
            html = {},
        }

        local lspconfig = require("lspconfig")
        for name, opt in pairs(opts) do
            lspconfig[name].setup(opt)
        end
    end,
}
