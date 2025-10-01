local function get_keys()
    local utility = require("utility")
    local window = require("config.window")
    local navigation = utility.lazy_require("nvim-tmux-navigation")

    local navigators = {
        h = navigation.NvimTmuxNavigateLeft(),
        j = navigation.NvimTmuxNavigateDown(),
        k = navigation.NvimTmuxNavigateUp(),
        l = navigation.NvimTmuxNavigateRight(),
    }

    local function wincmd(key)
        navigators[key]()
    end

    local keys = window.get_navigation_lazy_keys(wincmd)
    table.insert(keys, {
        [[<C-\>]],
        navigation.NvimTmuxNavigateLastActive(),
        mode = { "n", "t" },
    })
    -- table.insert(keys, {
    --     "<C-Space>",
    --     navigation.NvimTmuxNavigateNext(),
    --     mode = { "n", "t" },
    -- })

    return keys
end

return {
    "alexghergh/nvim-tmux-navigation",
    keys = get_keys(),
    opts = {
        disable_when_zoomed = true,
    },
}
