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

        local cmp = require("cmp")
        cmp.setup({
            -- window = {
            --     completion = cmp.config.window.bordered(),
            --     documentation = cmp.config.window.bordered(),
            -- },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
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
