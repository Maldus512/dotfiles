local vim = vim

return {
    name = "run script",
    builder = function(param)
        local file = vim.fn.expand("%:p")
        if param.file ~= nil then
            file = param.file
        end
        local cmd = { file }
        if param.interpreter ~= nil then
            cmd = { param.interpreter, file }
        elseif vim.bo.filetype == "go" then
            cmd = { "go", "run", file }
        end
        return {
            cmd = cmd,
            components = {
                { "on_output_quickfix", set_diagnostics = true },
                "on_result_diagnostics",
                "default",
            },
        }
    end,
    condition = {
        --filetype = { "sh", "python", "go", "lua" },
    },
}
