local R = require("config.utility").lazy_require
local aerial = R("aerial")

local function hijack_open_aerial_in_win()
    local aerial_window = require("aerial.window")
    local original_open_aerial_in_win = aerial_window.open_aerial_in_win

    ---@param src_bufnr integer source buffer
    ---@param src_winid integer window containing source buffer
    ---@param aer_winid integer aerial window
    aerial_window.open_aerial_in_win = function(src_bufnr, src_winid, aer_winid)
        local win = aer_winid == 0 and vim.api.nvim_get_current_win() or aer_winid
        local old_winfixbuf = vim.wo[win].winfixbuf

        vim.wo[win].winfixbuf = false
        original_open_aerial_in_win(src_bufnr, src_winid, aer_winid)
        vim.wo[win].winfixbuf = old_winfixbuf
    end
end

return {
    "stevearc/aerial.nvim",
    cmd = { "AerialOpen", "AerialToggle" },
    keys = {
        {
            "[s",
            aerial.prev(),
            desc = "Previous Symbol",
        },
        {
            "]s",
            aerial.next(),
            desc = "Next Symbol",
        },
        {
            "[S",
            aerial.prev_up(),
            desc = "Previous Higher Symbol",
        },
        {
            "]S",
            aerial.next_up(),
            desc = "Next Higher Symbol",
        },
    },
    opts = function()
        vim.api.nvim_set_hl(
            0,
            "AerialLine",
            vim.tbl_extend(
                "force",
                vim.api.nvim_get_hl(0, { name = "DiffAdd" }),
                { bold = true, italic = true }
            )
        )
        hijack_open_aerial_in_win()

        return {
            backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
            layout = {
                width = require("config.sidebar").width,
                win_opts = {
                    cursorline = true,
                    cursorcolumn = false,
                    winfixbuf = true,
                },
            },
            filter_kind = {
                json = { "Array", "Module" },
            },
            attach_mode = "global",
            keymaps = {
                ["<C-s>"] = false,
                ["<C-x>"] = "actions.jump_split",
                ["<C-j>"] = false,
                ["<C-k>"] = false,
                ["l"] = "actions.jump",
            },
            icons = {
                ["_"] = {
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
                },
                json = {
                    Module = "󰅩",
                },
            },
            show_guides = true,
            guides = {
                mid_item = "│ ",
                last_item = "└ ",
                nested_top = "│ ",
                whitespace = "  ",
            },
            lsp = {
                diagnostics_trigger_update = true,
                priority = {
                    copilot = 0,
                    vue_ls = 20,
                },
            },
        }
    end,
}
