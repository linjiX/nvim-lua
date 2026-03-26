local R = require("config.utility").lazy_require

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

---@param index "next" | "prev" | number
local function go_to(index)
    if vim.b.toggle_number == nil then
        return
    end

    local terms = require("toggleterm.terminal").get_all(true)
    vim.notify(vim.inspect(terms))
    vim.notify(terms.display_name)
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

    vim.api.nvim_win_set_buf(0, terms[target_index].bufnr)
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
            R("toggleterm").toggle(0, nil, nil, "vertical"),
            desc = "Toggle Terminal Vertically",
        },
        {
            "<M-s>",
            R("toggleterm").toggle(0, nil, nil, "horizontal"),
            desc = "Toggle Terminal",
        },
        {
            "<M-f>",
            R("toggleterm").toggle(0, nil, nil, "float"),
            desc = "Toggle Terminal",
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
