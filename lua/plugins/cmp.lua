local kind_icons = {
    Array = "󰅪",
    Boolean = "󰨙",
    Class = "𝓒",
    Constant = "",
    Constructor = "󰊕",
    Enum = "𝓔",
    EnumMember = "",
    Event = "",
    Field = "",
    File = "󰈙",
    Function = "󰊕",
    Interface = "",
    Key = "󰌋",
    Keyword = "󰌋",
    Method = "󰊕",
    Module = "",
    Namespace = "󰦮",
    Null = "󰟢",
    Number = "󰎠",
    Object = "󰅩",
    Operator = "󰆕",
    Package = "",
    Property = "",
    String = "",
    Struct = "󰆼",
    TypeParameter = "𝙏",
    Variable = "󰀫",
    Collapsed = "",
    Text = "󰉿",
    Value = "󰎠",
}

local sources = {
    nvim_lsp = "[LSP]",
    buffer = "[Buf]",
    path = "[Path]",
}

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        -- "hrsh7th/cmp-cmdline",
        -- "hrsh7th/cmp-nvim-lua",
        -- "saadparwaiz1/cmp_luasnip",
        -- "L3MON4D3/LuaSnip",
    },
    config = function()
        vim.opt.shortmess:append("c")

        vim.api.nvim_set_hl(0, "CmpNormal", { bg = "black" })

        local cmp = require("cmp")
        local copilot = require("copilot.suggestion")

        local window_opts = {
            border = "none",
            winhighlight = "Normal:CmpNormal,Search:None",
        }

        cmp.setup({
            window = {
                completion = cmp.config.window.bordered(window_opts),
                documentation = cmp.config.window.bordered(window_opts),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

                ["<Tab>"] = function(fallback)
                    local selection = cmp.get_selected_entry()
                    if copilot.is_visible() and not selection then
                        copilot.accept()
                        return
                    end

                    if cmp.visible() then
                        cmp.confirm({ select = true })
                        return
                    end

                    fallback()
                end,
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind

                    local source = sources[entry.source.name] or ""
                    local menu = vim_item.menu or ""

                    vim_item.menu = source ~= "" and ("%-6s %s"):format(source, menu) or menu

                    return vim_item
                end,
            },
        })

        -- local cmdline_mapping = {
        --     ["<TAB>"] = {
        --         c = function()
        --             if not cmp.visible() then
        --                 cmp.complete()
        --             end
        --             cmp.complete_common_string()
        --         end,
        --     },
        --     ["<C-j>"] = {
        --         c = function(fallback)
        --             if cmp.visible() then
        --                 cmp.select_prev_item()
        --             else
        --                 fallback()
        --             end
        --         end,
        --     },
        --     ["<C-k>"] = {
        --         c = function(fallback)
        --             if cmp.visible() then
        --                 cmp.select_next_item()
        --             else
        --                 fallback()
        --             end
        --         end,
        --     },
        -- }

        -- cmp.setup.cmdline("/", {
        --     mapping = cmdline_mapping,
        --     completion = { autocomplete = false },
        --     performance = {
        --         max_view_entries = 30,
        --     },
        --     sources = {
        --         { name = "buffer" },
        --     },
        --     view = {
        --         entries = {
        --             selection_order = "near_cursor",
        --         },
        --     },
        -- })
        --
        -- cmp.setup.cmdline(":", {
        --     mapping = cmdline_mapping,
        --     completion = { autocomplete = false },
        --     performance = {
        --         max_view_entries = 30,
        --     },
        --     sources = cmp.config.sources({
        --         { name = "path" },
        --     }, {
        --         { name = "cmdline" },
        --     }),
        --     view = {
        --         entries = {
        --             selection_order = "near_cursor",
        --         },
        --     },
        --     matching = {
        --         disallow_fuzzy_matching = true,
        --         disallow_fullfuzzy_matching = true,
        --         disallow_partial_fuzzy_matching = true,
        --         disallow_partial_matching = true,
        --         disallow_prefix_unmatching = false,
        --         disallow_symbol_nonprefix_matching = true,
        --     },
        --         -- disallow_fuzzy_matching = false,
        --         -- disallow_fullfuzzy_matching = false,
        --         -- disallow_partial_fuzzy_matching = true,
        --         -- disallow_partial_matching = false,
        --         -- disallow_prefix_unmatching = false,
        --         -- disallow_symbol_nonprefix_matching = true,
        --
        -- })
    end,
}
