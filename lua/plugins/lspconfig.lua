local function get_vue_plugin_path()
    return vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")
end

return {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },
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
                    config.settings.python.pythonPath = require("utility").get_python_path()
                end,
            },
            ruff = {},

            -- ts_ls = {
            --     settings = {
            --         typescript = {
            --             tsserver = {
            --                 maxTsServerMemory = 8192,
            --             },
            --         },
            --     },
            --     init_options = {
            --         hostInfo = "neovim",
            --         plugins = {
            --             {
            --                 name = "@vue/typescript-plugin",
            --                 location = get_vue_plugin_path(),
            --                 languages = { "vue" },
            --             },
            --         },
            --     },
            --     filetypes = { "typescript", "javascript", "vue" },
            -- },
            vtsls = {
                settings = {
                    typescript = {
                        tsserver = {
                            maxTsServerMemory = 8192,
                        },
                    },
                    vtsls = {
                        tsserver = {
                            globalPlugins = {
                                {
                                    name = "@vue/typescript-plugin",
                                    location = get_vue_plugin_path(),
                                    languages = { "vue" },
                                    configNamespace = "typescript",
                                },
                            },
                        },
                    },
                },
                filetypes = { "typescript", "javascript", "vue" },
            },
            vue_ls = {},
            eslint = {},
            html = {},
            bashls = {
                filetypes = { "bash", "zsh", "sh" },
            },
        }

        for name, opt in pairs(opts) do
            vim.lsp.config(name, opt)
        end
        vim.lsp.enable(vim.tbl_keys(opts))
    end,
}
