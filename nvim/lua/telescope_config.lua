require("telescope").load_extension("live_grep_args")
require("telescope").setup {
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
      },
    },
    sorting_strategy = "ascending",
    --- other configs
    mappings = {
        n = {
            ["<C-p>"] = false,
            ["<C-P>"] = false,
        },
        i = {
            ["<C-p>"] = false,
            ["<C-P>"] = false,
        },
    },
  },
}
