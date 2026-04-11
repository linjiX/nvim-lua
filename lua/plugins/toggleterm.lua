local R = require("config.utility").lazy_require

local function tmux_command(command)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ",")[1]
    return vim.fn.system(("tmux -S %s %s"):format(tmux_socket, command))
end

local function create_term_buffer(term)
    local window = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_create_buf(false, false)

    vim.api.nvim_win_set_buf(window, bufnr)
    term.window, term.bufnr = window, bufnr
    term:__set_options()
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

local function get_candidate_background_term()
    local candidate = nil

    for _, term in ipairs(get_background_terms()) do
        if candidate == nil or (term.leave_at or 0) > (candidate.leave_at or 0) then
            candidate = term
        end
    end

    return candidate
end

local function on_exit(term)
    local candidate = get_candidate_background_term()
    if candidate == nil or candidate.id == term.id then
        vim.cmd.quit()
        return
    end

    require("toggleterm.ui").switch_buf(candidate.bufnr)
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

local function new()
    local Terminal = require("toggleterm.terminal").Terminal
    local ui = require("toggleterm.ui")

    local term = Terminal:new()
    create_term_buffer(term)
    term:spawn()

    local parts = vim.split(term:_display_name(), "/", { plain = true, trimempty = true })
    term.display_name = parts[#parts]

    ui.hl_term(term)
end

local function split(cmd)
    vim.cmd(cmd)

    local term = get_candidate_background_term()
    if term ~= nil then
        require("toggleterm.ui").switch_buf(term.bufnr)
    else
        new()
    end
end

local function rename()
    local term_id = vim.b.toggle_number
    if term_id == nil then
        return
    end

    local term = require("toggleterm.terminal").get(term_id, true)
    if term == nil then
        return
    end

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

local function get_display_name(term)
    local terms = require("toggleterm.terminal").get_all(true)
    local index = get_term_index(term.id, terms)

    return ("%s  %s"):format(raise_number(index), term:_display_name())
end

local function set_winbar_highlights()
    local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

    vim.api.nvim_set_hl(0, "WinBarActive", { bold = true, italic = true, fg = directory_hl.fg })
end

local function set_keymaps(bufnr)
    vim.keymap.set({ "n" }, "<CR>", vim.cmd.startinsert, { buffer = bufnr })
    vim.keymap.set({ "n", "t" }, "<M-a>", new, { buffer = bufnr, desc = "New Terminal" })
    vim.keymap.set({ "n", "t" }, "<M-r>", rename, { buffer = bufnr, desc = "Rename Terminal" })

    vim.keymap.set({ "n", "t" }, "<M-h>", function()
        go_to("prev")
    end, { buffer = bufnr, desc = "Prev Terminal" })

    vim.keymap.set({ "n", "t" }, "<M-l>", function()
        go_to("next")
    end, { buffer = bufnr, desc = "Next Terminal" })

    for i = 1, 10 do
        vim.keymap.set({ "n", "t" }, ("<M-%d>"):format(i == 10 and 0 or i), function()
            go_to(i)
        end, { buffer = bufnr, desc = ("Go To Terminal %d"):format(i) })
    end
end

local function get_keys()
    local keys = {
        {
            "<M-v>",
            function()
                split("rightbelow vsplit")
            end,
            desc = "Right Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-s>",
            function()
                split("rightbelow split")
            end,
            desc = "Below Split Terminal",
            mode = { "n", "t" },
        },
        {
            "<M-V>",
            function()
                split("botright 70vsplit")
            end,
            desc = "Rightmost Split terminal",
            mode = { "n", "t" },
        },
        {
            "<M-S>",
            function()
                split("botright 20split")
            end,
            desc = "Bottom Split Terminal",
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
                tmux_command([[new-window -c "#{pane_current_path}"]])
            end,
            desc = "New Tmux Terminal",
        },
        {
            "<M-r>",
            function()
                tmux_command([[command-prompt -I "#W" 'rename-window "%%"']])
            end,
            desc = "Rename Tmux Terminal",
        },
    }

    for i = 1, 10 do
        table.insert(keys, {
            ("<M-%d>"):format(i == 10 and 0 or i),
            function()
                tmux_command(("select-window -t %d"):format(i))
            end,
            desc = ("Go To Tmux Terminal %d"):format(i),
        })
    end

    return keys
end

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = get_keys(),
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
            set_keymaps(term.bufnr)
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
        set_winbar_highlights()

        local augroup = vim.api.nvim_create_augroup("MyToggleTerm", { clear = true })
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = augroup,
            callback = set_winbar_highlights,
        })

        vim.api.nvim_create_autocmd("BufWinLeave", {
            group = augroup,
            pattern = "term://*",
            callback = function(args)
                local term_id = vim.b[args.buf].toggle_number
                if term_id == nil then
                    return
                end

                local term = require("toggleterm.terminal").get(term_id, true)
                if term == nil then
                    return
                end

                term.leave_at = vim.uv.now()
            end,
        })
    end,
}
