-- Our lua/utils.lua file

local M = {}

function M.get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))
  return vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
end

function M.basename(str)
    local name = string.gsub(str, "(.*/)(.*)", "%2")
    return name
end

function M.current_dir_basename()
    if vim then
        return M.basename(vim.fn.getcwd())
    else
        return ""
    end
end

function M.map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end

    if (type(mode) == "string") then
        mode = { mode }
    end

    for _, m in ipairs(mode) do
        local newrhs = rhs
        if (m == "i") then
            if type(rhs) == "string" then
                newrhs = "<Esc>" .. rhs
            else
                newrhs = function() vim.cmd.stopinsert() rhs() end
            end
        end
        vim.keymap.set(m, lhs, newrhs, options)
    end
end

return M
