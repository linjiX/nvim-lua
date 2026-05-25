local utility = require("config.utility")

---@class MyTerminal: Terminal
---@field leave_at? integer
---@field command_name? string
---@field order integer
---@field __set_options fun(self: Terminal)

---@class TermWindowOpts
---@field float? boolean
---@field vertical? boolean
---@field full? boolean
---@field size? integer

---@param command string
---@return string
local function tmux_command(command)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ",")[1]
    return vim.fn.system(("tmux -S %s %s"):format(tmux_socket, command))
end

---@param value boolean
---@return nil
local function set_cursor_marker(value)
    vim.opt_local.cursorline = value
    vim.opt_local.cursorcolumn = value
end

---@param opts? TermCreateArgs
---@return MyTerminal
local function create_term(opts)
    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new(opts)
    ---@cast term MyTerminal
    term.bufnr = vim.api.nvim_create_buf(false, false)

    return term
end

---@return MyTerminal[]
local function get_sorted_terms()
    local terms = require("toggleterm.terminal").get_all()
    ---@cast terms MyTerminal[]

    table.sort(terms, function(a, b)
        return a.order < b.order
    end)

    return terms
end

---@param term MyTerminal
---@param win integer
---@return nil
local function apply_term_window_options(term, win)
    term.window = win
    term:__set_options()

    vim.wo[win].signcolumn = "no"
    vim.wo[win].cursorline = false
    vim.wo[win].cursorcolumn = false
    vim.wo[win].winfixbuf = true

    local ui = require("toggleterm.ui")
    ui.hl_term(term)
    ui.set_winbar(term)
end

---@param term MyTerminal
---@return nil
local function spawn_term(term)
    term:spawn()

    local parts = vim.split(term:_display_name(), "/", { plain = true, trimempty = true })
    term.display_name = nil
    term.command_name = parts[#parts]
    term.order = term.id

    vim.schedule(vim.cmd.startinsert)
end

---@type table<string, string>
local superscript_numbers = {
    ["0"] = "⁰",
    ["1"] = "¹",
    ["2"] = "²",
    ["3"] = "³",
    ["4"] = "⁴",
    ["5"] = "⁵",
    ["6"] = "⁶",
    ["7"] = "⁷",
    ["8"] = "⁸",
    ["9"] = "⁹",
}

---@param number number
---@return string
local function raise_number(number)
    local raised = tostring(number):gsub("%d", function(digit)
        return superscript_numbers[digit]
    end)
    return raised
end

---@param current_id number
---@param terms Terminal[]
---@return integer?
local function get_term_index(current_id, terms)
    for i, v in ipairs(terms) do
        if v.id == current_id then
            return i
        end
    end
end

---@param term MyTerminal
---@return string
local function get_name(term)
    return term.display_name or term.command_name or ""
end

---@param term MyTerminal
---@param terms? MyTerminal[]
---@return string
local function get_display_name(term, terms)
    terms = terms or get_sorted_terms()
    local index = get_term_index(term.id, terms)
    local raised_index = index and raise_number(index) or "?"

    return ("%s  %s"):format(raised_index, get_name(term))
end

---@param active_id integer
---@return string
local function winbar(active_id)
    local terms = get_sorted_terms()
    local parts = { " " }

    for _, term in ipairs(terms) do
        local highlight = active_id == term.id and "WinBarActive" or "WinBarInactive"
        local name = get_display_name(term, terms):gsub("%%", "%%%%")

        table.insert(parts, ("%%#%s#%s%%*"):format(highlight, name))
        table.insert(parts, " ")
    end

    return table.concat(parts)
end

---@return MyTerminal[]
local function get_background_terms()
    local terms = get_sorted_terms()
    local has_open, windows = require("toggleterm.ui").find_open_windows()

    if not has_open then
        return terms
    end

    ---@type table<number, boolean>
    local open_term_ids = {}
    for _, window in ipairs(windows) do
        open_term_ids[window.term_id] = true
    end

    return vim.tbl_filter(function(term)
        return not open_term_ids[term.id]
    end, terms)
end

---@return MyTerminal?
local function get_candidate_background_term()
    return utility.max_by(get_background_terms(), function(term)
        return term.leave_at or 0
    end)
end

---@return MyTerminal?
local function get_current_term()
    local term_id = vim.b.toggle_number
    if term_id == nil then
        return nil
    end

    local term = require("toggleterm.terminal").get(term_id, true)
    ---@cast term MyTerminal?
    return term
end

local function switch_term(win, term)
    vim.wo[win].winfixbuf = false
    vim.api.nvim_win_set_buf(win, term.bufnr)
    vim.wo[win].winfixbuf = true
end

---@param term Terminal
---@return nil
local function on_exit(term)
    local candidate = term.hidden and nil or get_candidate_background_term()
    local wins = {}

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == term.bufnr then
            table.insert(wins, win)
        end
    end

    if not candidate then
        for _, win in ipairs(wins) do
            vim.api.nvim_win_close(win, false)
        end
        return
    end

    for _, win in ipairs(wins) do
        switch_term(win, candidate)
    end
end

---@param direction "next" | "prev" | number
---@return {source: MyTerminal, target: MyTerminal}?
local function get_direction_terms(direction)
    local source_id = vim.b.toggle_number
    if source_id == nil then
        return
    end

    local terms = get_sorted_terms()
    if #terms <= 1 then
        return
    end

    local source_index = get_term_index(source_id, terms)
    if source_index == nil then
        return
    end

    local target_index

    if direction == "next" then
        direction = source_index + 1
        target_index = direction > #terms and 1 or direction
    elseif direction == "prev" then
        direction = source_index - 1
        target_index = direction < 1 and #terms or direction
    else
        target_index = direction < 1 and 1 or direction > #terms and #terms or direction
    end

    if source_index == target_index then
        return
    end

    return {
        source = terms[source_index],
        target = terms[target_index],
    }
end

---@param direction "next" | "prev" | number
---@return nil
local function go_to(direction)
    local terms = get_direction_terms(direction)
    if not terms then
        return
    end

    local win = vim.api.nvim_get_current_win()

    switch_term(win, terms.target)

    if terms.target.window ~= win then
        apply_term_window_options(terms.target, win)
    end
end

---@param direction "next" | "prev"
---@return nil
local function move_term(direction)
    local terms = get_direction_terms(direction)
    if not terms then
        return
    end

    terms.source.order, terms.target.order = terms.target.order, terms.source.order

    require("toggleterm.ui").set_winbar(terms.source)
end

---@param direction "next" | "prev" | number
---@return fun()
local function switcher(direction)
    return function()
        go_to(direction)
    end
end

---@param direction "next" | "prev"
---@return fun()
local function mover(direction)
    return function()
        move_term(direction)
    end
end

---@return nil
local function new()
    local term = create_term()
    local win = vim.api.nvim_get_current_win()

    switch_term(win, term)
    spawn_term(term)
    apply_term_window_options(term, win)
end

---@param opts TermWindowOpts
---@param term MyTerminal
---@return nil
local function open_term_window(opts, term)
    local config
    if opts.float then
        config = require("toggleterm.ui")._get_float_config(term, true)
        config.border = nil
    else
        config = {
            split = opts.vertical and "right" or "below",
            width = opts.vertical and opts.size or nil,
            height = not opts.vertical and opts.size or nil,
            win = opts.full and -1 or 0,
        }
    end

    local win = vim.api.nvim_open_win(term.bufnr, true, config)
    if opts.float then
        vim.wo[win].sidescrolloff = 0
    elseif opts.full then
        if opts.vertical then
            vim.wo[win].winfixwidth = true
        else
            vim.wo[win].winfixheight = true
        end
    end

    if term.job_id == nil then
        spawn_term(term)
    end
    apply_term_window_options(term, win)
end

---@param opts TermWindowOpts
---@return nil
local function open(opts)
    local term = get_candidate_background_term()
    if term == nil then
        term = create_term()
    end

    open_term_window(opts, term)
end

---@param command string
---@return MyTerminal?
local function get_tool_term(command)
    local terms = require("toggleterm.terminal").get_all(true)
    ---@cast terms MyTerminal[]

    for _, term in ipairs(terms) do
        if
            term.hidden
            and term.cmd == command
            and term.job_id ~= nil
            and term.bufnr ~= nil
            and vim.api.nvim_buf_is_valid(term.bufnr)
        then
            return term
        end
    end
end

---@param command string
---@return nil
local function open_tool(command)
    local term = get_tool_term(command)
    if term == nil then
        term = create_term({
            cmd = command,
            close_on_exit = true,
            direction = "float",
            hidden = true,
        })
    end

    open_term_window({ float = true }, term)
end

---@return nil
local function input_tool()
    local term = get_current_term()
    if term ~= nil then
        term:persist_mode()
    end

    vim.cmd.stopinsert()
    vim.schedule(function()
        vim.ui.input({
            prompt = "Open terminal tool: ",
        }, function(input)
            if input == nil then
                return
            end

            local command = vim.trim(input)
            if command == "" then
                return
            end

            open_tool(command)
        end)
    end)
end

---@return nil
local function rename()
    local term = get_current_term()
    if term == nil then
        return
    end

    term:persist_mode()
    vim.cmd.stopinsert()
    vim.schedule(function()
        vim.ui.input({
            prompt = "Rename terminal: ",
            default = get_name(term),
        }, function(input)
            if input == nil or input == "" then
                return
            end

            term.display_name = vim.trim(input)
        end)
    end)
end

---@return nil
local function set_winbar_highlights()
    local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

    vim.api.nvim_set_hl(0, "WinBarActive", { bold = true, italic = true, fg = directory_hl.fg })
end

local function startinsert_trigger(key)
    return function()
        set_cursor_marker(false)
        return key
    end
end

---@param bufnr integer
---@return nil
local function set_keymaps(bufnr)
    ---@param mode string[]
    ---@param lhs string
    ---@param rhs string | function
    ---@param desc? string
    ---@param opts? vim.keymap.set.Opts
    ---@return nil
    local function map(mode, lhs, rhs, desc, opts)
        local keymap_opts = vim.tbl_extend("force", { desc = desc, buffer = bufnr }, opts or {})
        vim.keymap.set(mode, lhs, rhs, keymap_opts)
    end

    map({ "n", "t" }, "<M-a>", new, "New Terminal")
    map({ "n", "t" }, "<M-r>", rename, "Rename Terminal")
    map({ "n", "t" }, "<M-h>", switcher("prev"), "Prev Terminal")
    map({ "n", "t" }, "<M-l>", switcher("next"), "Next Terminal")
    map({ "n", "t" }, "<M-H>", mover("prev"), "Move Terminal Prev")
    map({ "n", "t" }, "<M-L>", mover("next"), "Move Terminal Next")

    map({ "n" }, "<CR>", "i", nil, { remap = true })
    for _, key in ipairs({ "i", "I", "a", "A" }) do
        map({ "n" }, key, startinsert_trigger(key), nil, { expr = true })
    end

    for i = 1, 10 do
        local desc = ("Go To Terminal %d"):format(i)
        map({ "n", "t" }, ("<M-%d>"):format(i == 10 and 0 or i), switcher(i), desc)
    end
end

local name_updater = require("snacks").util.debounce(function()
    local term = get_current_term()
    if term == nil or term.display_name ~= nil then
        return
    end

    local term_id = term.id
    utility.get_terminal_command_async(term.bufnr, function(command)
        if command == nil then
            return
        end

        local target_term = require("toggleterm.terminal").get(term_id, true)
        ---@cast target_term MyTerminal?
        if target_term and target_term.display_name == nil then
            target_term.command_name = command
        end
    end)
end, { ms = 100 })

local function name_update_trigger(key)
    return function()
        name_updater()
        return key
    end
end

---@return LazyKeysSpec[]
local function get_keys()
    local keys = {
        {
            "<ESC><ESC>",
            function()
                vim.cmd.stopinsert()
                vim.schedule(function()
                    set_cursor_marker(true)
                end)
            end,
            desc = "Exit Terminal Mode",
            mode = "t",
        },
        {
            "<M-v>",
            function()
                open({ vertical = true })
            end,
            desc = "Right Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-s>",
            function()
                open({ vertical = false })
            end,
            desc = "Below Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-V>",
            function()
                open({ vertical = true, full = true, size = 80 })
            end,
            desc = "Rightmost Split terminal",
            mode = { "n", "t" },
        },
        {
            "<M-S>",
            function()
                open({ vertical = false, full = true, size = 20 })
            end,
            desc = "Bottom Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-f>",
            function()
                open({ float = true })
            end,
            desc = "Open Floating Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-F>",
            input_tool,
            desc = "Open Terminal Tool",
            mode = { "n", "t" },
        },
        {
            "<M-a>",
            function()
                tmux_command([[new-window -c "#{pane_current_path}"]])
            end,
            desc = "New Tmux Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-r>",
            function()
                tmux_command([[command-prompt -I "#W" 'rename-window "%%"']])
            end,
            desc = "Rename Tmux Terminal",
            mode = { "n", "t" },
        },
    }

    for _, lhs in ipairs({ "<CR>", "<C-c>", "<C-d>" }) do
        table.insert(keys, {
            lhs,
            name_update_trigger(lhs),
            expr = true,
            mode = "t",
        })
    end

    for i = 1, 10 do
        table.insert(keys, {
            ("<M-%d>"):format(i == 10 and 0 or i),
            function()
                tmux_command(("select-window -t %d"):format(i))
            end,
            desc = ("Go To Tmux Terminal %d"):format(i),
            mode = { "n", "t" },
        })
    end

    return keys
end

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = get_keys(),
    opts = {
        open_mapping = [[<c-\>]],
        ---@param term Terminal
        on_create = function(term)
            if not term.hidden then
                set_keymaps(term.bufnr)
            end
        end,
        on_exit = on_exit,

        close_on_exit = false,
        shade_terminals = false,
        -- shading_factor = -100,

        highlights = {
            Normal = {
                guifg = "#c7c7c7",
                guibg = "#000000",
            },
            NormalFloat = {
                guifg = "#c7c7c7",
                guibg = "#000000",
            },
            FloatBorder = {
                link = "FloatBorder",
            },
        },

        direction = "customized",

        winbar = {
            enabled = true,
            name_formatter = get_display_name,
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
        require("toggleterm.ui").winbar = winbar
        set_winbar_highlights()

        local augroup = vim.api.nvim_create_augroup("MyToggleTerm", { clear = true })
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = augroup,
            callback = set_winbar_highlights,
        })

        vim.api.nvim_create_autocmd("BufWinLeave", {
            group = augroup,
            pattern = "term://*",
            callback = function()
                local term = get_current_term()
                if term == nil then
                    return
                end

                ---@cast term MyTerminal
                term.leave_at = vim.uv.now()
                term:persist_mode()
                vim.cmd.stopinsert()
            end,
        })

        vim.api.nvim_create_autocmd("WinLeave", {
            group = augroup,
            pattern = "term://*",
            callback = function()
                vim.cmd.stopinsert()
            end,
        })
    end,
}
