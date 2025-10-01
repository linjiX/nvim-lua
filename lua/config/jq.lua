local M = {}

local JQ_KEYMAPS = {
    { key = [[<Leader>jq]], cmd = "!jq -M -r --indent 4", desc = "Format JSON with jq" },
    { key = [[<Leader>jc]], cmd = "!jq -M -c", desc = "Compact JSON with jq" },
    { key = [[<Leader>j\]], cmd = "!jq -M @json", desc = "Escape JSON with jq" },
}

function M.setup()
    for _, map in ipairs(JQ_KEYMAPS) do
        local opts = { silent = true, desc = map.desc }
        vim.keymap.set("n", map.key, ":%" .. map.cmd .. "<CR>", opts)
        vim.keymap.set("x", map.key, ":" .. map.cmd .. "<CR>", opts)
    end
end

return M
