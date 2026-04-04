local R = require("config.utility").lazy_require

local function tmux_command(command)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ",")[1]
    return vim.fn.system(("tmux -S %s %s"):format(tmux_socket, command))
end

-- this function is copyed from "toggleterm.nvim/lua/toggleterm/ui.lua"
local function create_term_buf_if_needed(term)
    local api = vim.api
    local valid_win = term.window and api.nvim_win_is_valid(term.window)
    local window = valid_win and term.window or api.nvim_get_current_win()
    -- If the buffer doesn't exist create a new one
    local valid_buf = term.bufnr and api.nvim_buf_is_valid(term.bufnr)
    local bufnr = valid_buf and term.bufnr or api.nvim_create_buf(false, false)
    -- Assign buf to window to ensure window options are set correctly
    api.nvim_win_set_buf(window, bufnr)
    term.window, term.bufnr = window, bufnr
    term:__set_options()
    api.nvim_set_current_buf(bufnr)
end

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

local function raise_number(number)
    return tostring(number):gsub("%d", function(digit)
        return superscript_numbers[digit]
    end)
end

local function get_term_index(current_id, terms)
    for i, v in ipairs(terms) do
        if v.id == current_id then
            return i
        end
    end
end

local function on_exit(term)
    local terms = require("toggleterm.terminal").get_all(true)
    local other_terms = vim.tbl_filter(function(t)
        return t.id ~= term.id
    end, terms)

    if #other_terms == 0 then
        vim.cmd.quit()
        return
    end

    require("toggleterm.ui").switch_buf(other_terms[1].bufnr)
end

---@param index "next" | "prev" | number
local function go_to(index)
    if vim.b.toggle_number == nil then
        return
    end

    local terms = require("toggleterm.terminal").get_all(true)
    if #terms <= 1 then
        return
    end

    local source_index = get_term_index(vim.b.toggle_number, terms)
    local target_index

    if index == "next" then
        index = source_index + 1
        target_index = index > #terms and 1 or index
    elseif index == "prev" then
        index = source_index - 1
        target_index = index < 1 and #terms or index
    else
        target_index = index < 1 and 1 or index > #terms and #terms or index
    end

    if source_index == target_index then
        return
    end

    local term = terms[target_index]

    local ui = require("toggleterm.ui")
    ui.switch_buf(term.bufnr)
end

local function new(direction)
    local Terminal = require("toggleterm.terminal").Terminal
    local ui = require("toggleterm.ui")

    local terminal = Terminal:new({ direction = direction })
    create_term_buf_if_needed(terminal)
    ui.hl_term(terminal)
    terminal:spawn()
    ui.switch_buf(terminal.bufnr)
end

local function get_background_terms()
    local terms = require("toggleterm.terminal").get_all(true)
    local has_open, windows = require("toggleterm.ui").find_open_windows()

    if not has_open then
        return terms
    end

    local open_term_ids = {}
    for _, window in ipairs(windows) do
        open_term_ids[window.term_id] = true
    end

    return vim.tbl_filter(function(term)
        return not open_term_ids[term.id]
    end, terms)
end

local function vsplit()
    vim.cmd("rightbelow vsplit")

    local terms = get_background_terms()
    if #terms > 0 then
        local ui = require("toggleterm.ui")
        ui.switch_buf(terms[1].bufnr)
    else
        new("vertical")
    end
end

local function split()
    vim.cmd("rightbelow split")

    local terms = get_background_terms()
    if #terms > 0 then
        local ui = require("toggleterm.ui")
        ui.switch_buf(terms[1].bufnr)
    else
        new("horizontal")
    end
end

local function get_display_name(term)
    local terms = require("toggleterm.terminal").get_all(true)
    local index = get_term_index(term.id, terms)

    return ("%s  %s"):format(raise_number(index), term:_display_name())
end

local function set_winbar_highlights()
    local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

    vim.api.nvim_set_hl(0, "WinBarActive", { bold = true, italic = true, fg = directory_hl.fg })
end

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,

    keys = {
        {
            "<M-v>",
            vsplit,
            desc = "Toggle Terminal Vertically",
            mode = { "n", "t" },
        },
        {
            "<M-s>",
            split,
            desc = "Toggle Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-f>",
            R("toggleterm").toggle(0, nil, nil, "float"),
            desc = "Toggle Terminal",
        },
        {
            "<M-a>",
            function()
                tmux_command('new-window -c "#{pane_current_path}"')
            end,
            desc = "New Tmux Terminal",
        },
        {
            "<M-a>",
            function()
                new("vertical")
            end,
            desc = "New Terminal",
            mode = "t",
        },
        {
            "<M-h>",
            function()
                go_to("prev")
            end,
            desc = "Prev Terminal",
            mode = "t",
        },
        {
            "<M-l>",
            function()
                go_to("next")
            end,
            desc = "Next Terminal",
            mode = "t",
        },
    },
    opts = {
        size = function(term)
            -- vim.notify(vim.inspect(term))
            if term.direction == "horizontal" then
                return 20
            elseif term.direction == "vertical" then
                return vim.api.nvim_win_get_width(0)
            end
        end,
        open_mapping = [[<c-\>]],
        on_create = function(term)
            if term.direction == "vertical" then
                vim.opt_local.winfixwidth = false
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

        direction = "vertical",

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

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("MyToggleTermWinbar", { clear = true }),
            callback = set_winbar_highlights,
        })
    end,
}
