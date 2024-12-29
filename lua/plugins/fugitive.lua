local function tabopen()
    local view = vim.fn.winsaveview()
    vim.cmd("tabedit %")
    vim.fn.winrestview(view)
end

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
    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
        cmd = { "Gst", "Git" },
        keys = {
            { "gb", ":GBrowse<CR>" },
            { "gb", ":GBrowse<CR>", mode = "x" },
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
            vim.api.nvim_create_user_command("Gst", ":vertical botright Git", {})
            vim.api.nvim_create_user_command("Gc", function(opts)
                local args = opts.args or ""
                vim.cmd("vertical botright Git commit -v " .. args)
            end, {
                nargs = "?",
                complete = function(ArgLead, CmdLine, CursorPos)
                    return vim.fn["fugitive#CommitComplete"](ArgLead, CmdLine, CursorPos)
                end,
            })
            vim.api.nvim_create_user_command("Gca", function(opts)
                local args = opts.args or ""
                vim.cmd("vertical botright Git commit -av " .. args)
            end, {
                nargs = "?",
                complete = function(ArgLead, CmdLine, CursorPos)
                    return vim.fn["fugitive#CommitComplete"](ArgLead, CmdLine, CursorPos)
                end,
            })
            vim.api.nvim_create_user_command("Gblame", function(opts)
                tabopen()
                vim.cmd("Git blame --date=short" .. opts.args)

                vim.keymap.set("n", "<leader>q", ":tabclose<CR>", { buffer = true, silent = true })
                vim.keymap.set("n", "q", ":tabclose<CR>", { buffer = true, silent = true })
            end, {
                nargs = "?",
                complete = function(ArgLead, CmdLine, CursorPos)
                    return vim.fn["fugitive#BlameComplete"](ArgLead, CmdLine, CursorPos)
                end,
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
        end,
    },
    {
        "tpope/vim-rhubarb",
        dependencies = { "tpope/vim-fugitive" },
    },
}
