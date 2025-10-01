vim.g.conflict_marker_enable_mappings = 0

return {
    "rhysd/conflict-marker.vim",
    lazy = false,
    keys = {
        { "]k", "<Plug>(conflict-marker-next-hunk)", desc = "Next Git Conflict" },
        { "[k", "<Plug>(conflict-marker-prev-hunk)", desc = "Previous Git Conflict" },

        { "<Leader>cj", "<Plug>(conflict-marker-themselves)", desc = "Git Conflict Choose Theirs" },
        { "<Leader>ck", "<Plug>(conflict-marker-ourselves)", desc = "Git Conflict Choose Ours" },
        { "<Leader>cn", "<Plug>(conflict-marker-none)", desc = "Git Conflict Choose None" },
        { "<Leader>cb", "<Plug>(conflict-marker-both)", desc = "Git Conflict Choose Both" },
        {
            "<Leader>cr",
            "<Plug>(conflict-marker-both-rev)",
            desc = "Git Conflict Choose Both Reversed",
        },
    },
    config = function()
        vim.api.nvim_set_hl(0, "ConflictMarkerBegin", { bg = "#2f7366" })
        vim.api.nvim_set_hl(0, "ConflictMarkerOurs", { bg = "#2e5049" })
        vim.api.nvim_set_hl(0, "ConflictMarkerTheirs", { bg = "#344f69" })
        vim.api.nvim_set_hl(0, "ConflictMarkerEnd", { bg = "#2f628e" })
        vim.api.nvim_set_hl(0, "ConflictMarkerCommonAncestorsHunk", { bg = "#754a81" })
    end,
}
-- return {
--     "akinsho/git-conflict.nvim",
--     version = "*",
--     lazy = false,
--     keys = {
--         { "<Leader>cj", "<Plug>(git-conflict-theirs)", desc = "Git Conflict Choose Theirs" },
--         { "<Leader>ck", "<Plug>(git-conflict-ours)", desc = "Git Conflict Choose Ours" },
--         { "<Leader>cb", "<Plug>(git-conflict-both)", desc = "Git Conflict Choose Both" },
--         { "<Leader>cn", "<Plug>(git-conflict-none)", desc = "Git Conflict Choose None" },
--         { "]k", "<Plug>(git-conflict-next-conflict)", desc = "Next Git Conflict" },
--         { "[k", "<Plug>(git-conflict-prev-conflict)", desc = "Previous Git Conflict" },
--     },
--     opts = function()
--         vim.api.nvim_create_autocmd("User", {
--             group = vim.api.nvim_create_augroup("MyGitConflict", { clear = true }),
--             pattern = "GitConflictDetected",
--             callback = function()
--                 vim.notify("Git Conflict Detected")
--             end,
--         })
--
--         return {}
--     end,
-- }
