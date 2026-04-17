local command = require("config.utility").lazy_require("copilot.command")

-- This function is copied from "copilot-lsp" and update autocmds to limit NES on Normal mode
---@param client vim.lsp.Client
---@param augroup integer
local function hijack_lsp_on_init(client, augroup)
    local debounced_request = require("copilot-lsp.util").debounce(
        require("copilot-lsp.nes").request_nes,
        vim.g.copilot_nes_debounce or 500
    )
    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        callback = function()
            debounced_request(client)
        end,
        group = augroup,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            local td_params = vim.lsp.util.make_text_document_params()
            client:notify("textDocument/didFocus", {
                textDocument = {
                    uri = td_params.uri,
                },
            })
        end,
        group = augroup,
    })
end

return {
    "zbirenbaum/copilot.lua",
    dependencies = {
        "AndreM222/copilot-lualine",
        {
            "copilotlsp-nvim/copilot-lsp",
            opts = function()
                require("copilot-lsp.nes").lsp_on_init = hijack_lsp_on_init
            end,
        },
    },
    cmd = "Copilot",
    event = "InsertEnter",
    keys = {
        {
            "<Tab>",
            function()
                local suggestion = require("copilot.suggestion")
                if not suggestion.is_visible() then
                    vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
                    return
                end

                suggestion.accept()
            end,
            mode = "i",
            desc = "Accept Copilot Suggestion",
        },
        { "[rg", command.enable(), desc = "Enable Copilot" },
        { "]rg", command.disable(), desc = "Disable Copilot" },
        { "yrg", command.toggle(), desc = "Toggle Copilot" },
    },
    opts = {
        panel = {
            keymap = {
                jump_prev = "<C-k>",
                jump_next = "<C-j>",
                accept = "<CR>",
                refresh = "r",
                open = "<C-l>",
            },
            layout = {
                position = "right",
            },
        },
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = false,
                accept_word = false,
                accept_line = false,
                next = "<C-j>",
                prev = "<C-k>",
                dismiss = "<C-e>",
            },
        },
        nes = {
            enabled = true,
            auto_trigger = true,
            keymap = {
                accept_and_goto = "<Tab>",
                accept = "<S-Tab>",
                dismiss = "<C-e>",
            },
        },
        filetypes = {
            gitcommit = true,
            AvanteInput = false,
        },
    },
}
