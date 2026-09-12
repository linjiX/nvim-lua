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
    Color = "",
    Snippet = "",
}

---@param action "next" | "prev" | "dismiss"
---@return fun(): boolean?
local function copilot_action(action)
    return function()
        local suggestion = require("copilot.suggestion")
        if not suggestion.is_visible() then
            return
        end

        suggestion[action]()
        return true
    end
end

---@return nil
local function set_menu_highlights()
    vim.api.nvim_set_hl(0, "BlinkCmpNormal", { bg = "black" })

    -- tokyonight ships no BlinkCmpLabelDescription/BlinkCmpSource, so they fall back to
    -- PmenuExtra. Match nvim-cmp's CmpItemMenu, which the theme renders in the comment color.
    local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    for _, group in ipairs({ "BlinkCmpLabelDescription", "BlinkCmpSource" }) do
        vim.api.nvim_set_hl(0, group, { fg = comment.fg })
    end
end

local source_labels = {
    lsp = "[LSP]",
    buffer = "[Buf]",
    path = "[Path]",
}

return {
    "saghen/blink.cmp",
    enabled = false,
    dependencies = { "saghen/blink.lib" },
    build = function()
        require("blink.cmp").build():pwait()
    end,
    event = "InsertEnter",
    opts = {
        appearance = {
            nerd_font_variant = "mono",
            kind_icons = kind_icons,
        },
        keymap = {
            preset = "none",
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-e>"] = { "cancel", copilot_action("dismiss"), "fallback" },
            ["<C-j>"] = { "select_next", copilot_action("next"), "fallback" },
            ["<C-k>"] = { "select_prev", copilot_action("prev"), "fallback" },
            ["<Tab>"] = {
                function(cmp)
                    local copilot = require("copilot.suggestion")
                    if copilot.is_visible() and not cmp.get_selected_item() then
                        copilot.accept()
                        return true
                    end
                end,
                "select_and_accept",
                "fallback",
            },
        },
        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = true,
                },
            },
            menu = {
                border = "none",
                winhighlight = "Normal:BlinkCmpNormal,CursorLine:BlinkCmpMenuSelection,Search:None",
                draw = {
                    columns = {
                        { "kind_icon" },
                        { "label", gap = 1 },
                        { "source_id", "label_description", gap = 1 },
                    },
                    components = {
                        source_id = {
                            text = function(ctx)
                                return source_labels[ctx.source_id] or ""
                            end,
                            highlight = "BlinkCmpSource",
                        },
                    },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 0,
                window = {
                    border = "none",
                    winhighlight = "Normal:BlinkCmpNormal,Search:None",
                },
            },
            -- copilot.lua already draws inline suggestions
            ghost_text = { enabled = false },
        },
        sources = {
            -- the lsp and path providers fall back to buffer when they return nothing
            default = { "lsp", "path", "buffer" },
        },
        cmdline = { enabled = false },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    config = function(_, opts)
        vim.opt.shortmess:append("c")

        set_menu_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("MyBlinkCmp", { clear = true }),
            callback = set_menu_highlights,
        })

        require("blink.cmp").setup(opts)
    end,
}
