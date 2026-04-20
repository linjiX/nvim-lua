local R = require("config.utility").lazy_require
local cli = R("sidekick.cli")

local DEFAULT_CLI = "codex"

local function attach_default_cli()
    local session = require("sidekick.cli.session")
    local tool = require("sidekick.cli.tool")
    local state = require("sidekick.cli.state")

    session.setup()
    return state.attach({ tool = tool.get(DEFAULT_CLI) })
end

local function get_cli_state()
    local states = require("sidekick.cli.state").get({
        attached = true,
        cwd = true,
        terminal = true,
    })

    if #states > 0 then
        return states[1]
    end
end

local function open_cli()
    local state = get_cli_state()
    if state then
        state.terminal:focus()
        return
    end

    attach_default_cli()
end

local function sender(msg)
    return function()
        local _, text = cli.render({ msg = msg })()
        if not text then
            return
        end

        local state = get_cli_state() or attach_default_cli()

        cli.send({ text = text, filter = { session = state.session.id } })()
    end
end

return {
    "folke/sidekick.nvim",
    lazy = false,
    keys = {
        {
            "<Tab>",
            function()
                if not require("sidekick").nes_jump_or_apply() then
                    vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
                end
            end,
            desc = "Goto/Apply Next Edit Suggestion",
        },
        {
            "<Leader>aa",
            open_cli,
            mode = "n",
            desc = "Sidekick Open",
        },
        {
            "<Leader>aa",
            sender("{this}"),
            mode = "x",
            desc = "Sidekick Send This",
        },
        {
            "<Leader>as",
            cli.select(),
            desc = "Sidekick Select CLI",
        },
        {
            "<Leader>aq",
            cli.hide(),
            desc = "Sidekick Hide",
        },
        {
            "<Leader>aQ",
            cli.close(),
            desc = "Sidekick Close",
        },
        {
            "<Leader>af",
            sender("{file}"),
            desc = "Sidekick Send File",
        },
        {
            "<Leader>ay",
            sender("{selection}"),
            mode = "x",
            desc = "Sidekick Send Text",
        },
        {
            "<Leader>ad",
            sender("{diagnostics}"),
            desc = "Sidekick Send Diagnostics",
        },
        {
            "<Leader>aD",
            sender("{diagnostics_all}"),
            desc = "Sidekick Send All Diagnostics",
        },
        {
            "<Leader>am",
            sender("{function}"),
            desc = "Sidekick Send Function",
        },
        {
            "<Leader>an",
            sender("{class}"),
            desc = "Sidekick Send Class",
        },
        {
            "<Leader>ab",
            sender("{buffers}"),
            desc = "Sidekick Send All Buffers",
        },
        {
            "<Leader>ap",
            cli.prompt(),
            mode = { "n", "x" },
            desc = "Sidekick Select Prompt",
        },
    },
    opts = {
        cli = {
            mux = {
                enabled = true,
                backend = "tmux",
            },
            picker = "telescope",
        },
    },
}
