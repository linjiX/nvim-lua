local utility = require("config.utility")
local toggleterm = utility.lazy_require("toggleterm")

---@class MyTerminal: Terminal
---@field leave_at? integer
---@field __set_options fun(self: Terminal)

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

---@param term Terminal
---@return nil
local function create_term_buffer(term)
    local window = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_create_buf(false, false)

    vim.api.nvim_win_set_buf(window, bufnr)
    term.window, term.bufnr = window, bufnr
    ---@cast term MyTerminal
    term:__set_options()
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

---@return MyTerminal[]
local function get_background_terms()
    local terms = require("toggleterm.terminal").get_all(true)
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

local function get_current_term()
    local term_id = vim.b.toggle_number
    if term_id == nil then
        return nil
    end

    return require("toggleterm.terminal").get(term_id, true)
end

---@param term Terminal
---@return nil
local function on_exit(term)
    local candidate = get_candidate_background_term()
    if candidate == nil or candidate.id == term.id then
        vim.cmd.quit()
        return
    end

    require("toggleterm.ui").switch_buf(candidate.bufnr)
end

---@param direction "next" | "prev" | number
---@return nil
local function go_to(direction)
    local source_id = vim.b.toggle_number
    if source_id == nil then
        return
    end

    local terms = require("toggleterm.terminal").get_all(true)
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

    local term = terms[target_index]

    local ui = require("toggleterm.ui")
    ui.switch_buf(term.bufnr)
end

---@param direction "next" | "prev" | number
---@return fun()
local function switcher(direction)
    return function()
        go_to(direction)
    end
end

---@return nil
local function new()
    local Terminal = require("toggleterm.terminal").Terminal
    local ui = require("toggleterm.ui")

    local term = Terminal:new()
    create_term_buffer(term)
    term:spawn()

    local parts = vim.split(term:_display_name(), "/", { plain = true, trimempty = true })
    term.display_name = parts[#parts]

    ui.hl_term(term)
    vim.schedule(vim.cmd.startinsert)
end

---@param modifier string
---@return nil
local function split(modifier)
    vim.cmd(("%s split"):format(modifier))
    if modifier:find("bot", 1, true) or modifier:find("top", 1, true) then
        if modifier:find("vertical", 1, true) then
            vim.opt_local.winfixwidth = true
        else
            vim.opt_local.winfixheight = true
        end
    end

    local term = get_candidate_background_term()
    if term ~= nil then
        require("toggleterm.ui").switch_buf(term.bufnr)
    else
        new()
    end
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
            default = term.display_name or "",
        }, function(input)
            if input == nil or input == "" then
                return
            end

            term.display_name = vim.trim(input)
        end)
    end)
end

---@param term Terminal
---@return string
local function get_display_name(term)
    local terms = require("toggleterm.terminal").get_all(true)
    local index = get_term_index(term.id, terms)
    local raised_index = index and raise_number(index) or "?"

    return ("%s  %s"):format(raised_index, term:_display_name())
end

---@return nil
local function set_winbar_highlights()
    local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

    vim.api.nvim_set_hl(0, "WinBarActive", { bold = true, italic = true, fg = directory_hl.fg })
end

---@param bufnr integer
---@return nil
local function set_keymaps(bufnr)
    ---@param mode string[]
    ---@param lhs string
    ---@param rhs function
    ---@param desc? string
    ---@return nil
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map({ "n" }, "<CR>", vim.cmd.startinsert)
    map({ "n", "t" }, "<M-a>", new, "New Terminal")
    map({ "n", "t" }, "<M-r>", rename, "Rename Terminal")
    map({ "n", "t" }, "<M-h>", switcher("prev"), "Prev Terminal")
    map({ "n", "t" }, "<M-l>", switcher("next"), "Next Terminal")

    for i = 1, 10 do
        local desc = ("Go To Terminal %d"):format(i)
        map({ "n", "t" }, ("<M-%d>"):format(i == 10 and 0 or i), switcher(i), desc)
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
                split("rightbelow vertical")
            end,
            desc = "Right Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-s>",
            function()
                split("rightbelow")
            end,
            desc = "Below Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-V>",
            function()
                split("botright vertical 70")
            end,
            desc = "Rightmost Split terminal",
            mode = { "n", "t" },
        },
        {
            "<M-S>",
            function()
                split("botright 20")
            end,
            desc = "Bottom Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-f>",
            toggleterm.toggle(0, nil, nil, "float"),
            desc = "Toggle Terminal",
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
            set_keymaps(term.bufnr)
            set_cursor_marker(false)
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

        float_opts = {
            border = "rounded",
        },
        winbar = {
            enabled = true,
            name_formatter = get_display_name,
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
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

        vim.api.nvim_create_autocmd("InsertEnter", {
            group = augroup,
            pattern = "term://*",
            callback = function()
                set_cursor_marker(false)
            end,
        })
    end,
}
