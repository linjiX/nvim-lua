return {
    "edkolev/tmuxline.vim",
    enabled = false,
    config = function()
        vim.g.tmuxline_preset = {
            a = "Tmux",
            b = "Session: #S",
            c = "",
            win = "#I.#W#F",
            cwin = "#I.#W#F",
            x = { "#(whoami)@#H", "%F %a", "#{cpu_fg_color}#{cpu_icon} #{cpu_percentage}" },
            z = "%R",
            options = {
                ["status-justify"] = "left",
                ["status-position"] = "top",
            },
        }
    end,
}
