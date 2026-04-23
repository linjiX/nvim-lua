local function get_vue_plugin_path()
    return vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")
end

local function is_nvim_config_buffer(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if not path then
        return false
    end

    return vim.fs.relpath(vim.fn.stdpath("config"), path) ~= nil
end

local function lua_root_dir_getter(root_markers)
    return function(bufnr, on_dir)
        if is_nvim_config_buffer(bufnr) then
            return
        end

        on_dir(vim.fs.root(bufnr, root_markers))
    end
end

local function get_nvim_lua_root_dir(bufnr, on_dir)
    if is_nvim_config_buffer(bufnr) then
        on_dir(vim.fn.stdpath("config"))
    end
end

local function get_nvim_lua_library()
    local root = require("config.lazy").root

    local library = { vim.env.VIMRUNTIME }

    if vim.uv.fs_stat(root) then
        vim.list_extend(library, vim.fn.globpath(root, "*", false, true))
    end

    return library
end

return {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        { "[oj", vim.cmd.LspStart },
        { "]oj", vim.cmd.LspStop },
        { "yoJ", vim.cmd.LspRestart },
    },
    config = function()
        local lua_ls = assert(vim.lsp.config.lua_ls, "lua_ls config is not available")

        ---@type table<string, vim.lsp.Config>
        local opts = {
            lua_ls = {
                root_dir = lua_root_dir_getter(lua_ls.root_markers),
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        workspace = {
                            library = { vim.env.VIMRUNTIME },
                        },
                    },
                },
            },
            lua_ls_nvim = vim.tbl_deep_extend("force", vim.deepcopy(lua_ls), {
                root_markers = nil,
                root_dir = get_nvim_lua_root_dir,
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        workspace = {
                            checkThirdParty = "Disable",
                            library = get_nvim_lua_library(),
                        },
                    },
                },
            }),
            vimls = {},
            jsonls = {},
            taplo = {},

            pyright = {
                before_init = function(_, config)
                    ---@diagnostic disable-next-line: inject-field
                    config.settings.python.pythonPath = require("config.utility").get_python_path()
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
            tailwindcss = {},
            bashls = {
                filetypes = { "bash", "zsh", "sh" },
            },
            dockerls = {},
            docker_compose_language_service = {},
            yamlls = {},
        }

        for name, opt in pairs(opts) do
            vim.lsp.config(name, opt)
        end
        vim.lsp.enable(vim.tbl_keys(opts))
    end,
}
