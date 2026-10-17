local R = require("config.utility").lazy_require
local aerial = R("aerial")

local function hijack_open_aerial_in_win()
    local aerial_window = require("aerial.window")
    local original_open_aerial_in_win = aerial_window.open_aerial_in_win

    ---@param src_bufnr integer source buffer
    ---@param src_winid integer window containing source buffer
    ---@param aer_winid integer aerial window
    ---@diagnostic disable-next-line: duplicate-set-field
    aerial_window.open_aerial_in_win = function(src_bufnr, src_winid, aer_winid)
        local win = aer_winid == 0 and vim.api.nvim_get_current_win() or aer_winid
        vim.wo[win].winfixbuf = false

        original_open_aerial_in_win(src_bufnr, src_winid, aer_winid)

        vim.wo[win].winfixbuf = true
    end
end

--- `aerial.backends.lsp.on_attach` asks `backends.attach` to refresh, but that call short
--- circuits whenever the *backend* is unchanged. So when a slow client attaches after the
--- `lsp` backend is already active, aerial keeps the symbols it fetched from whichever
--- client happened to win the startup race and never queries the new one.
---
--- On vue files `vtsls` attaches first and answers `textDocument/documentSymbol` with
--- `nil`, so the outline keeps whatever treesitter put there. Re-fetch whenever the client
--- that just attached is the one aerial would actually ask.
local function hijack_lsp_on_attach()
    local lsp = require("aerial.backends.lsp")
    local lsp_util = require("aerial.backends.lsp.util")
    local backends = require("aerial.backends")

    local on_attach = lsp.on_attach

    ---@param client vim.lsp.Client
    ---@param bufnr? integer
    ---@diagnostic disable-next-line: duplicate-set-field
    lsp.on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not lsp_util.client_supports_symbols(client) then
            return
        end

        -- `on_attach` schedules the backend attach, so this has to run after it
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end

            local preferred = lsp_util.get_client(bufnr)
            if
                preferred
                and preferred.id == client.id
                and backends.is_backend_attached(bufnr, "lsp")
            then
                lsp.fetch_symbols(bufnr)
            end
        end)
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
        hijack_lsp_on_attach()

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
                priority = {
                    copilot = 0,
                    vue_ls = 20,
                },
            },
        }
    end,
}
