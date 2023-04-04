require("tint").setup({
    tint = -24,
    saturation = .65,
    tint_background_colors = false,
    highlight_ignore_patterns = { "WinSeparator", "Status.*" }, -- Highlight group patterns to ignore, see `string.find`
    window_ignore_function = function(winid)
        local bufid = vim.api.nvim_win_get_buf(winid)
        local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
        local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

        --local curid = vim.api.nvim_get_current_win()
        --local curbufid = vim.api.nvim_win_get_buf(curid)
        --local current_window_buftype = vim.api.nvim_buf_get_option(curbufid, "buftype")
        if (current_window_buftype == "terminal") then
            return true
        else
            -- Do not tint `terminal` or floating windows, tint everything else
            return buftype == "terminal" or floating
        end
    end
})


vim.api.nvim_create_autocmd({ "TermEnter" }, {
    callback = function()
        require("tint").disable()
        print("Entered in terminal")
    end, -- Or myvimfun
})

vim.api.nvim_create_autocmd({ "TermLeave" }, {
    callback = function()
        require("tint").enable()
        print("Exited in terminal")
    end, -- Or myvimfun
})
