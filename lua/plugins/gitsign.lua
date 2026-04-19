local tabopen = require("config.utility").tabopen

local function iter_upvalue_functions(fn)
    return coroutine.wrap(function()
        local i = 1
        while true do
            local name, value = debug.getupvalue(fn, i)
            if not name then
                return
            end
            if type(value) == "function" then
                coroutine.yield(i, name, value)
            end
            i = i + 1
        end
    end)
end

local function get_upvalue_function(fn, target)
    for _, name, value in iter_upvalue_functions(fn) do
        if name == target then
            return value
        end
    end
end

local function is_committed(sha)
    return sha and tonumber("0x" .. sha) ~= 0
end

local function hijack_blame()
    local blame = require("gitsigns.actions.blame").blame
    local patched = {
        on_cursor_moved = false,
        pmap = false,
        reblame = false,
        show_commit = false,
    }

    --- @return string?
    local function get_sha(blm_win, entries)
        local row = vim.api.nvim_win_get_cursor(blm_win)[1]
        local sha = assert(entries[row]).commit.sha
        if not is_committed(sha) then
            return nil
        end
        return sha
    end

    for i, name, value in iter_upvalue_functions(blame) do
        if name == "on_cursor_moved" then
            local original = value

            local replacement = function(bufnr, blm_win, entries, commit_lines, commit_summaries)
                local summaries = {}
                for line in pairs(commit_summaries or {}) do
                    summaries[line] = false
                end
                return original(bufnr, blm_win, entries, commit_lines, summaries)
            end

            debug.setupvalue(blame, i, replacement)
            patched.on_cursor_moved = true
        elseif name == "pmap" then
            local original = value

            local replacement = function(mode, lhs, cb, opts)
                opts = vim.tbl_extend("force", opts or {}, { nowait = true })
                return original(mode, lhs, cb, opts)
            end

            debug.setupvalue(blame, i, replacement)
            patched.pmap = true
        elseif name == "reblame" then
            local original = value

            local replacement = function(opts, entries, win, revision, parent)
                local sha = get_sha(vim.api.nvim_get_current_win(), entries)
                if not sha then
                    vim.notify("Cannot reblame an uncommitted line", vim.log.levels.WARN)
                    return
                end

                return original(opts, entries, win, revision, parent)
            end

            debug.setupvalue(blame, i, replacement)
            patched.reblame = true
        elseif name == "show_commit" then
            local original = value

            local replacement = function(win, bwin, open, bcache)
                local sha = get_sha(bwin, bcache.blame.entries)
                if not sha then
                    vim.notify("No commit yet for the current line", vim.log.levels.WARN)
                    return
                end

                return original(win, bwin, open, bcache)
            end

            debug.setupvalue(blame, i, replacement)
            patched.show_commit = true
        end

        if patched.on_cursor_moved and patched.pmap and patched.reblame and patched.show_commit then
            return
        end
    end
end

local function find_blame_source_buf()
    local current = vim.api.nvim_get_current_win()

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win ~= current and vim.api.nvim_win_is_valid(win) and vim.wo[win].scrollbind then
            return vim.api.nvim_win_get_buf(win)
        end
    end
end

local function blame_line_in_blame()
    local source_buf = assert(find_blame_source_buf())
    local bcache = assert(require("gitsigns.cache").cache[source_buf])

    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local info = assert(bcache:get_blame(lnum, {}))

    local result = require("gitsigns.util").convert_blame_info(info)
    local popup = require("gitsigns.popup")
    local config = require("gitsigns.config").config

    if not is_committed(result.sha) then
        popup.create({ { { result.author, "Label" } } }, config.preview_config, "blame")
        return
    end

    local blame_line = require("gitsigns.actions.blame_line")
    local create_blame_title_linespec =
        assert(get_upvalue_function(blame_line, "create_blame_title_linespec"))

    local title = create_blame_title_linespec(result, bcache.git_obj.repo, false)
    popup.create({ title, { { result.summary, "NormalFloat" } } }, config.preview_config, "blame")
end

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
                tabopen()
                vim.opt_local.winfixbuf = true
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
    config = function(_, opts)
        require("gitsigns").setup(opts)
        hijack_blame()
    end,
    blame_line_in_blame = blame_line_in_blame,
}
