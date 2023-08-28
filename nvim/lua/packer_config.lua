local vim = vim

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packages.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    use "arthurxavierx/vim-unicoder"

    -- Debuggers
    use { 'mfussenegger/nvim-dap' }
    use { "sakhnik/nvim-gdb", run = "./install.sh" }
    use { 'simrat39/rust-tools.nvim', requires = { 'neovim/nvim-lspconfig', 'mfussenegger/nvim-dap',
        'nvim-lua/plenary.nvim' } }

    -- Colorschemes
    use 'Mofiqul/vscode.nvim'
    use "savq/melange-nvim"
    use { "adisen99/apprentice.nvim", requires = { "rktjmp/lush.nvim" } }
    use { "ellisonleao/gruvbox.nvim" }
    use 'ful1e5/onedark.nvim'
    use 'shaunsingh/nord.nvim'
    use 'folke/tokyonight.nvim'
    use { "catppuccin/nvim", as = "catppuccin" }
    use "EdenEast/nightfox.nvim"
    use "rafamadriz/neon"

    use("sindrets/winshift.nvim")
    use("levouh/tint.nvim")
    use "lukas-reineke/virt-column.nvim"

    use { "ziglang/zig.vim" }
    use { "brooth/far.vim" }
    use { "nvim-pack/nvim-spectre", requires = { "nvim-lua/plenary.nvim" } }

    use('mrjones2014/smart-splits.nvim')
    use { 'lewis6991/gitsigns.nvim', tag = 'release' }
    use { "nvim-tree/nvim-tree.lua", as = "nvim-tree" }
    use "Asheq/close-buffers.vim"
    use { "neoclide/coc.nvim", branch = "release" }
    use {
        "nvim-telescope/telescope.nvim", tag = "0.1.1",
        -- or                            , branch = "0.1.x",
        requires = { { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end,
    }

    use { "nvim-zh/colorful-winsep.nvim" }

    -- under consideration
    use { "nvim-tree/nvim-web-devicons" }
    use { "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons", opt = true } }
    use { "romgrk/barbar.nvim", requires = "nvim-tree/nvim-web-devicons" }
    --diffview.nvim

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use { "lukas-reineke/indent-blankline.nvim", required = { "nvim-treesitter/nvim-treesitter" } }
    --use {"aserowy/tmux.nvim"}
    use { "akinsho/toggleterm.nvim" }
    use { 'anuvyklack/hydra.nvim' }
    use {
        "klen/nvim-config-local",
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
