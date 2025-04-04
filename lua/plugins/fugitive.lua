return {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "Gw", "Gst", "Gc", "Gca", "Gblame" },
    keys = {
        { "gb", vim.cmd.GBrowse, mode = { "n", "x" } },
        {
            "q",
            "gq",
            ft = { "fugitive", "fugitiveblame" },
            remap = true,
            desc = "Quit Fugitive",
        },
        {
            "<Leader>q",
            "gq",
            ft = { "fugitive", "fugitiveblame" },
            remap = true,
            desc = "Quit Fugitive",
        },
    },
    init = function()
        for _, rhs in ipairs({"Git", "Gst", "Gc", "Gca"}) do
            local lhs = rhs:lower()
            vim.keymap.set("ca", lhs, function()
                return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs and rhs or lhs
            end, { expr = true })
        end
    end,
    config = function()
        local utility = require("utility")
        local window = require("utility.window")

        local scriptname = "vim-fugitive/autoload/fugitive.vim"

        local function redirect_to_floatwin()
            local width = 120
            local height = math.floor(vim.go.lines * 0.9)
            local row = math.floor((vim.go.lines - height) / 2)
            local col = math.floor((vim.go.columns - width) / 2)

            local opts = {
                enter = true,
                win_config = {
                    relative = "editor",
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    border = "rounded",
                },
            }
            local win = window.redirect_win(opts)
            vim.wo[win].winfixbuf = true
            return win
        end

        local function is_commit_id(target)
            return target and #target >= 7 and #target <= 40 and target:match("^[0-9a-f]+$")
        end

        vim.api.nvim_create_user_command("Git", function(opts)
            local subcommand = opts.args:match("%w+")
            local mods = (opts.mods ~= "" or subcommand == "blame") and opts.mods
                or "botright vertical"

            local command = vim.fn["fugitive#Command"](
                opts.line1,
                opts.count,
                opts.range,
                opts.bang,
                mods,
                opts.args
            )

            local source_buf = vim.api.nvim_get_current_buf()
            vim.cmd(command)
            if
                source_buf ~= vim.api.nvim_get_current_buf()
                and vim.list_contains({ "commit", "rebase" }, subcommand)
            then
                redirect_to_floatwin()
            end
        end, {
            nargs = "?",
            range = true,
            bang = true,
            complete = vim.fn["fugitive#Complete"],
        })

        vim.api.nvim_create_user_command("Gst", "Git", {})

        vim.api.nvim_create_user_command("Gc", function(opts)
            vim.cmd("Git commit --verbose " .. opts.args)
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#CommitComplete"],
        })

        vim.api.nvim_create_user_command("Gca", function(opts)
            vim.cmd("Git commit --verbose --all " .. opts.args)
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#CommitComplete"],
        })

        vim.api.nvim_create_user_command("Gblame", function(opts)
            utility.tabopen()
            vim.wo.winfixbuf = true
            vim.cmd("Git blame --date=short" .. opts.args)

            vim.keymap.set("n", "<Leader>q", vim.cmd.tabclose, { buffer = true })
            vim.keymap.set("n", "q", vim.cmd.tabclose, { buffer = true })

            local BlameCommit = utility.get_script_function("BlameCommit", scriptname)
            assert(BlameCommit)

            vim.keymap.set("n", "<CR>", function()
                local splitbelow = vim.o.splitbelow
                vim.opt.splitbelow = true

                local ok, result = pcall(function()
                    vim.cmd(BlameCommit("vsplit"))
                end)
                vim.opt.splitbelow = splitbelow

                if not ok then
                    error(result)
                end
            end, { buffer = true })
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#BlameComplete"],
        })

        local augroup = vim.api.nvim_create_augroup("FugitiveAutocmd", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = "fugitive",
            callback = function()
                vim.opt_local.number = false
                vim.opt_local.buflisted = false

                local GF = utility.get_script_function("GF", scriptname)
                local CfilePorcelain = utility.get_script_function("CfilePorcelain", scriptname)
                assert(GF and CfilePorcelain)

                vim.keymap.set("n", "<CR>", function()
                    local target = CfilePorcelain()[1]
                    if is_commit_id(target) then
                        vim.cmd(GF("split"))
                        redirect_to_floatwin()
                    else
                        vim.cmd(GF("edit"))
                    end
                end, { buffer = true })
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = "fugitiveblame",
            callback = function()
                vim.opt_local.listchars:remove({ "precedes", "extends" })
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = "git",
            callback = function()
                vim.opt_local.buflisted = false

                vim.keymap.set("n", "<Leader>q", ":q<CR>", { buffer = true, silent = true })
                vim.keymap.set("n", "q", ":q<CR>", { buffer = true, silent = true })
            end,
        })
    end,
}
