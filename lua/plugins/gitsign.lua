return {
    "lewis6991/gitsigns.nvim",
    opts = {
        on_attach = function(buffer)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
            end

            map("n", "]h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gs.nav_hunk("next")
                end
            end, "Next Hunk")
            map("n", "[h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gs.nav_hunk("prev")
                end
            end, "Prev Hunk")

            map("n", "]H", function()
                gs.nav_hunk("last")
            end, "Last Hunk")
            map("n", "[H", function()
                gs.nav_hunk("first")
            end, "First Hunk")

            map("n", "<Leader>ga", gs.stage_hunk, "Stage Hunk")
            map("v", "<Leader>ga", function()
                gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end)
            map("n", "<Leader>gA", gs.stage_buffer, "Stage Buffer")

            map("n", "<Leader>gu", gs.reset_hunk, "Reset Hunk")
            map("v", "<Leader>gu", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end)
            map("n", "<Leader>gU", gs.reset_buffer, "Reset Buffer")

            map("n", "<Leader>gr", gs.undo_stage_hunk, "Undo Stage Hunk")
            map("n", "<Leader>gp", gs.preview_hunk, "Preview Hunk")
            map("n", "<Leader>gP", gs.preview_hunk_inline, "Preview Hunk Inline")

            map("n", "<Leader>gm", function()
                gs.blame_line({ full = true })
            end, "Blame Line")
            map("n", "<Leader>gM", function()
                gs.blame()
            end, "Blame Buffer")

            map("n", "<Leader>gd", gs.diffthis, "Diff This")
            map("n", "<Leader>gD", function()
                gs.diffthis("~")
            end, "Diff This ~")

            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
    },
}
