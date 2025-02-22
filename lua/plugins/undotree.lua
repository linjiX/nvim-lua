return {
    "mbbill/undotree",
    cmd = "Undotree",
    keys = {
        { "<Leader>U", vim.cmd.UndotreeToggle },
    },
    config = function()
        vim.g.undotree_SplitWidth = 70
        vim.g.undotree_WindowLayout = 3
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.g.undotree_DiffpanelHeight = 15
        vim.g.undotree_DiffCommand = "diff -u4 --label '' --label ''"
    end,
}
