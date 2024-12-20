require("toggleterm").setup {
    shade_terminals = true,
    open_mapping = [[<c-x>]],
    insert_mappings = true,   -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    on_create = function(term)
        if term.direction == "horizontal" then
            term:resize(20)
        elseif term.direction == "vertical" then
            term:resize(80)
        end
    end
}
