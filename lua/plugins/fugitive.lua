local scriptname = "vim-fugitive/autoload/fugitive.vim"

return {
    "tpope/vim-fugitive",
    scriptname = scriptname,
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "Gw", "Gst", "Gc", "Gca", "Gblame" },
    keys = {
        { "gb", vim.cmd.GBrowse, mode = { "n", "x" } },
    },
    init = function()
        for _, rhs in ipairs({ "Git", "Gst", "Gc", "Gca" }) do
            local lhs = rhs:lower()
            vim.keymap.set("ca", lhs, function()
                return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs and rhs or lhs
            end, { expr = true })
        end
    end,
    config = function()
        local utility = require("utility")
        local window = require("utility.window")

        vim.api.nvim_create_user_command("Git", function(opts)
            local subcommand = opts.args:match("%w+")
            local mods = (opts.mods ~= "" or subcommand == "blame") and opts.mods
                or "botright vertical"

            vim.cmd(
                vim.fn["fugitive#Command"](
                    opts.line1,
                    opts.count,
                    opts.range,
                    opts.bang,
                    mods,
                    opts.args
                )
            )
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
            vim.opt_local.winfixbuf = true
            vim.cmd("Git blame --date=short" .. opts.args)

            window.set_quit_keymaps(vim.cmd.tabclose)

            vim.keymap.set("n", "<CR>", function()
                local splitbelow = vim.o.splitbelow
                vim.opt.splitbelow = true

                local BlameCommit = utility.get_script_function("BlameCommit", scriptname)
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
    end,
}
