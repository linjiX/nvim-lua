local navigation = require("utility").lazy_require("nvim-tmux-navigation")

return {
    "alexghergh/nvim-tmux-navigation",
    keys = {
        {
            "<C-h>",
            navigation.NvimTmuxNavigateLeft(),
            mode = { "n", "t" },
        },
        {
            "<C-j>",
            navigation.NvimTmuxNavigateDown(),
            mode = { "n", "t" },
        },
        {
            "<C-k>",
            navigation.NvimTmuxNavigateUp(),
            mode = { "n", "t" },
        },
        {
            "<C-l>",
            navigation.NvimTmuxNavigateRight(),
            mode = { "n", "t" },
        },
        {
            "<C-\\>",
            navigation.NvimTmuxNavigateLastActive(),
            mode = { "n", "t" },
        },
        -- {
        --     "<C-Space>",
        --     navigation.NvimTmuxNavigateNext(),
        --     mode = { "n", "t" },
        -- },
    },
    opts = {
        disable_when_zoomed = true,
    },
}
