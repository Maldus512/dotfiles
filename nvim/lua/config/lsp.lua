local lspconfig = vim.lsp.config

lspconfig("clangd",
    {
        cmd = { "/home/maldus/.espressif/tools/esp-clang/15.0.0-23786128ae/esp-clang/bin/clangd", "--background-index", "-header-insertion=never", '--query-driver="/home/maldus/.arduino15/packages/*/tools/**/*-gcc,/home/maldus/.arduino15/packages/*/tools/**/*-g++"' }
    })
lspconfig("rust_analyzer", {})
lspconfig("zls", {
        cmd = { "zls" },
        filetypes = { "zig", "zir" },
        root_dir = vim.fs.find("build.zig", ".git") or vim.loop.cwd,
        single_file_support = true,
    })


vim.api.nvim_create_autocmd("LspAttach", {

    callback = function(args)
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Go to definition

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)   -- Hover info
    end,

})
