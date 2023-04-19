--[[
vim.o.background = "dark"
vim.g.apprentice_contrast_dark = "soft"
vim.g.apprentice_italic = true
vim.g.apprentice_italicize_comments = true
vim.cmd("colorscheme apprentice")
]]
--vim.opt.termguicolors = true
--vim.cmd.colorscheme 'melange'

--[[
local c = require('vscode.colors').get_colors()
require('vscode').setup({
    -- Alternatively set style in setup
    style = 'dark',
    -- Enable transparent background
    transparent = false,
    -- Enable italic comment
    italic_comments = true,
    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,
    -- Override colors (see ./lua/vscode/colors.lua)
    color_overrides = {},
    -- Override highlight groups (see ./lua/vscode/theme.lua)
    group_overrides = {},
})
require('vscode').load()
]]

vim.o.background = "dark" -- or "light" for light mode

--require('onedark').setup()


vim.g.nord_contrast = true
vim.g.nord_borders = true
vim.g.nord_italic = false

-- Load the colorscheme
--require('nord').set()
--

vim.g.apprentice_contrast_dark = "soft"
vim.g.apprentice_italic = true
vim.g.apprentice_italicize_comments = true


require("tokyonight").setup({
    style = "storm",
})

-- Default options
require('nightfox').setup({
    options = {
        dim_inactive = false,
    }
})

--require("tint_config")

--vim.cmd("colorscheme catppuccin-frappe")
vim.cmd("colorscheme nordfox")
--vim.cmd("colorscheme apprentice")
--vim.cmd("colorscheme gruvbox")
