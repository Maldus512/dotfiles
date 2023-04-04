-- Our lua/utils.lua file

local M = {}

function M.map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end

    if (type(mode) == "string") then
        mode = {mode}
    end

    for _, m in ipairs(mode) do
        if (m == "i") then
            rhs = "<Esc>" .. rhs
        end
        vim.api.nvim_set_keymap(m, lhs, rhs, options)
    end
end

return M
