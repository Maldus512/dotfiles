require("overseer").setup({
    templates = { "builtin", "run_script" },
    task_list = {
        default_detail = 2,
        bindings = {
            ["?"] = "ShowHelp",
            ["g?"] = "ShowHelp",
            ["<CR>"] = "RunAction",
            ["o"] = "Open",
            ["p"] = "TogglePreview",
            ["<C-k>"] = "IncreaseDetail",
            ["<C-j>"] = "DecreaseDetail",
            ["["] = "DecreaseWidth",
            ["]"] = "IncreaseWidth",
            ["{"] = "PrevTask",
            ["}"] = "NextTask",
            ["<C-y>"] = "ScrollOutputUp",
            ["<C-e>"] = "ScrollOutputDown",
            ["q"] = "Close",
        },
        direction = "right",
    },
})
