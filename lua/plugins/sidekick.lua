local utility = require("config.utility")
local cli = utility.lazy_require("sidekick.cli")

local CLIS = {
    "codex",
    "claude",
    "copilot",
}

local CLI_PRIORITIES = {}
for i, name in ipairs(CLIS) do
    CLI_PRIORITIES[name] = #CLIS - i + 1
end

---@class ConfigSidekickTerminal: sidekick.cli.Terminal
---@field hijacked? boolean
---@field win_closed_at? integer

local augroup = vim.api.nvim_create_augroup("MySidekick", { clear = true })

---@param terminal sidekick.cli.Terminal
local function configure_terminal(terminal)
    ---@cast terminal ConfigSidekickTerminal
    if terminal.hijacked then
        return
    end

    local open_win = terminal.open_win
    function terminal:open_win()
        local was_open = self:is_open()
        local ret = open_win(self)

        if not was_open and self.win then
            vim.api.nvim_create_autocmd("WinClosed", {
                group = augroup,
                pattern = tostring(self.win),
                once = true,
                callback = function()
                    self.win_closed_at = vim.uv.now()
                end,
            })
        end

        return ret
    end

    terminal.hijacked = true
end

---@param name string
---@return sidekick.cli.State
local function attach_cli(name)
    local Session = require("sidekick.cli.session")
    local Tool = require("sidekick.cli.tool")
    local State = require("sidekick.cli.state")

    Session.setup()
    local state, _ = State.attach({ tool = Tool.get(name) })
    return state
end

---@param name? string
---@return sidekick.cli.State?
local function get_attached_cli(name)
    local filter = { attached = true, cwd = true, terminal = true, name = name }
    local states = require("sidekick.cli.state").get(filter)

    if #states == 0 then
        return nil
    end

    ---@type sidekick.cli.State[]
    local opened_states = {}
    ---@type sidekick.cli.State[]
    local closed_states = {}

    for _, state in ipairs(states) do
        local terminal = state.terminal
        if terminal and terminal:is_open() then
            table.insert(opened_states, state)
        else
            table.insert(closed_states, state)
        end
    end

    if #opened_states > 0 then
        return utility.max_by(opened_states, function(state)
            return CLI_PRIORITIES[state.tool.name] or 0
        end)
    end

    return utility.max_by(closed_states, function(state)
        local terminal = state.terminal
        ---@cast terminal ConfigSidekickTerminal?
        return terminal and terminal.win_closed_at or 0
    end)
end

---@param name? string
---@return sidekick.cli.State, boolean
local function get_state(name)
    local state = get_attached_cli(name)
    if state then
        return state, false
    end

    return attach_cli(name or CLIS[1]), true
end

---@param name? string
---@return fun()
local function opener(name)
    return function()
        local state = get_state(name)
        if state.terminal then
            state.terminal:focus()
        end
    end
end

---@param state sidekick.cli.State
local function block_input_till_sent(state)
    local terminal = state.terminal
    if not terminal then
        return
    end

    local ns = vim.api.nvim_create_namespace("sidekick_block_input_till_sent")
    local done = false
    local seen_queue = false

    vim.on_key(function()
        if not done and terminal:is_focused() and vim.fn.mode() == "t" then
            return ""
        end
    end, ns)

    local function unblock()
        if done then
            return
        end
        done = true
        vim.on_key(nil, ns)
    end

    local function poll()
        if done then
            return
        end

        if #terminal.send_queue > 0 then
            seen_queue = true
        elseif seen_queue then
            return vim.defer_fn(unblock, 50)
        end

        vim.defer_fn(poll, 50)
    end

    vim.defer_fn(unblock, 3000)
    vim.defer_fn(poll, 50)
end

---@param msg string
---@param name? string
---@return fun()
local function sender(msg, name)
    return function()
        -- Set the visit time if the sidekick is lazy loaded
        if not vim.w.sidekick_visit then
            vim.w.sidekick_visit = vim.uv.hrtime()
        end

        local _, text = cli.render({ msg = msg })()
        if not text then
            return
        end

        local state, attached = get_state(name)
        if attached then
            block_input_till_sent(state)
        end

        cli.send({ text = text, filter = { session = state.session.id } })()
    end
end

---@return LazyKeysSpec[]
local function get_keys()
    local keys = {
        {
            "<Tab>",
            function()
                local nes = require("sidekick.nes")
                if nes.have() then
                    nes.jump()
                    nes.apply()
                    return
                end
                vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
            end,
            desc = "Apply Next Edit Suggestion",
        },
        {
            "<Leader>aa",
            opener(),
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
    }

    for i, name in ipairs(CLIS) do
        local lhs = ("<Leader>a%d"):format(i)
        local display_name = utility.capitalize(name)
        table.insert(keys, {
            lhs,
            opener(name),
            desc = ("Sidekick Open %s"):format(display_name),
        })
        table.insert(keys, {
            lhs,
            sender("{this}", name),
            desc = ("Sidekick Send To %s"):format(display_name),
            mode = "x",
        })
    end

    return keys
end

return {
    "folke/sidekick.nvim",
    event = "InsertEnter",
    keys = get_keys(),
    opts = {
        cli = {
            win = {
                config = configure_terminal,
                keys = {
                    shift_enter = {
                        "<S-CR>",
                        function(terminal)
                            vim.api.nvim_chan_send(terminal.job, "\027[13;2u")
                        end,
                        mode = "t",
                        desc = "Send Shift+Enter",
                    },
                },
            },
            mux = {
                enabled = true,
                backend = "tmux",
            },
            picker = "telescope",
        },
    },
}
