return {
    "lewis6991/gitsigns.nvim",
    opts = {
        on_attach = function(buffer)
            local gs = package.loaded.gitsigns

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
            end

            map("n", "]c", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gs.nav_hunk("next")
                end
            end, "Next Change")
            map("n", "[c", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gs.nav_hunk("prev")
                end
            end, "Prev Change")

            map("n", "]C", function()
                gs.nav_hunk("last")
            end, "Last Change")
            map("n", "[C", function()
                gs.nav_hunk("first")
            end, "First Change")

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

            map({ "o", "x" }, "ic", gs.select_hunk, "Select Change")
            map({ "o", "x" }, "ac", gs.select_hunk, "Select Change")
        end,
    },
}
