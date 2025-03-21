-- local script_functions = {}

-- local function get_script_snr(bufname)
--     local scriptnames = vim.api.nvim_exec2("scriptnames", { output = true })
--
--     for line in scriptnames:gmatch("[^\n]+") do
--         local snr, name = line:match("(%d+):%s*(.*)")
--         if name and name:match(bufname) then
--             return tonumber(snr)
--         end
--     end
--     return -1
-- end
--
-- local function get_script_function(name, filename)
--     if script_functions[name] then
--         return script_functions[name]
--     end
--
--     local snr = get_script_snr(filename)
--     if snr == -1 then
--         return nil
--     end
--
--     local function_name = ("<SNR>%d_%s"):format(snr, name)
--     if vim.fn.exists("*" .. function_name) == 1 then
--         script_functions[name] = vim.fn[function_name]
--         return script_functions[name]
--     end
--
--     return nil
-- end

return {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "Gst", "Gc", "Gca", "Gblame" },
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
        -- {
        --     "<CR>",
        --     function() end,
        --     ft = "fugitiveblame",
        -- },
    },
    config = function()
        vim.api.nvim_create_user_command("Git", function(opts)
            local mods = (opts.mods ~= "" or vim.startswith(opts.args, "blame")) and opts.mods
                or "botright vertical"

            local command = vim.fn["fugitive#Command"](
                opts.line1,
                opts.count,
                opts.range,
                opts.bang,
                mods,
                opts.args
            )
            vim.cmd(command)
        end, {
            nargs = "?",
            range = true,
            bang = true,
            complete = vim.fn["fugitive#Complete"],
        })

        vim.api.nvim_create_user_command("Gst", "Git", {})

        vim.api.nvim_create_user_command("Gc", function(opts)
            vim.cmd("Git commit -v " .. opts.args)
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#CommitComplete"],
        })

        vim.api.nvim_create_user_command("Gca", function(opts)
            vim.cmd("Git commit -av " .. opts.args)
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#CommitComplete"],
        })

        local utility = require("config.utility")
        vim.api.nvim_create_user_command("Gblame", function(opts)
            utility.tabopen()
            vim.cmd("Git blame --date=short" .. opts.args)

            vim.keymap.set("n", "<Leader>q", vim.cmd.tabclose, { buffer = true })
            vim.keymap.set("n", "q", vim.cmd.tabclose, { buffer = true })
        end, {
            nargs = "?",
            complete = vim.fn["fugitive#BlameComplete"],
        })

        local augroup = vim.api.nvim_create_augroup("FugitiveAutocmd", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = "fugitive",
            callback = function()
                vim.opt_local.buflisted = false
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = "fugitiveblame",
            callback = function()
                vim.opt_local.listchars:remove({ "precedes", "extends" })
            end,
        })

        local abbreviations = {
            git = "Git",
            gst = "Gst",
            gc = "Gc",
            gca = "Gca",
        }

        for lhs, rhs in pairs(abbreviations) do
            vim.keymap.set("ca", lhs, function()
                if vim.fn.getcmdtype() == ":" then
                    return rhs
                end
                return lhs
            end, { expr = true })
        end
    end,
}
