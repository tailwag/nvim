-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.harpoon")
vim.opt.relativenumber = true
require('lspconfig').pylsp.setup{
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true,
                    ignore = {'E221'},
                    maxLineLength = 100,
                },
            },
        },
    },
}

