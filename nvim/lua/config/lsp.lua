local lspconfig = require("lspconfig")

lspconfig.clangd.setup {
    cmd = { "/home/maldus/.espressif/tools/esp-clang/15.0.0-23786128ae/esp-clang/bin/clangd", "--background-index", "-header-insertion=never" }
}
lspconfig.rust_analyzer.setup {}
