local R = require("config.utility").lazy_require

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
            -- name_formatter = function(term)
            --     return term.name
            -- end,

            name_formatter = function(term)
                return string.format(" %d:%s", term.id, term:_display_name())
            end,
        },
    },
}
