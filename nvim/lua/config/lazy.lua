local vim = vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Local
    { dir = "/home/maldus/Projects/Maldus512/speaker.nvim" },

    "arthurxavierx/vim-unicoder",

    -- Package management
    { "williamboman/mason.nvim", build = ":MasonUpdate" },

    -- Debuggers
    'mfussenegger/nvim-dap',
    { "sakhnik/nvim-gdb",        build = "./install.sh" },

    -- Colorschemes
    { "EdenEast/nightfox.nvim",  priority = 1000 },
    { "catppuccin/nvim",         priority = 1000 },
    { "folke/tokyonight.nvim",   priority = 1000 },
    { "RRethy/nvim-base16",      priority = 1000 },
    { "mcchrish/zenbones.nvim",  priority = 1000,       dependencies = "rktjmp/lush.nvim" },

    -- Ui
    "stevearc/dressing.nvim",
    "rcarriga/nvim-notify",

    -- Language support
    "alaviss/nim.nvim",

    -- Development
    "stevearc/overseer.nvim",

    "sindrets/winshift.nvim",
    "levouh/tint.nvim",
    "lukas-reineke/virt-column.nvim",

    "ziglang/zig.vim",
    "brooth/far.vim",
    { "nvim-pack/nvim-spectre",  dependencies = { "nvim-lua/plenary.nvim" } },

    'mrjones2014/smart-splits.nvim',
    { 'lewis6991/gitsigns.nvim', tag = 'release' },
    { "nvim-tree/nvim-tree.lua", name = "nvim-tree" },
    "Asheq/close-buffers.vim",
    { "neoclide/coc.nvim",          branch = "release" },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        -- or                            , branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        --config = function() require("telescope").load_extension("live_grep_args") end,
    },

    -- windows and layout
    "nvim-zh/colorful-winsep.nvim",
    { "knubie/vim-kitty-navigator", build = "cp ./*.py ~/.config/kitty" },

    -- under consideration
    "rebelot/heirline.nvim",
    { "nvim-tree/nvim-web-devicons" },
    { "romgrk/barbar.nvim",         dependencies = { "nvim-tree/nvim-web-devicons" } },
    --diffview.nvim

    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
    },
    { "lukas-reineke/indent-blankline.nvim", dependencies = { "nvim-treesitter/nvim-treesitter" } },
    "akinsho/toggleterm.nvim",
    "anuvyklack/hydra.nvim",
    "klen/nvim-config-local",

})
