local status, reader = pcall(require, "reader")
if status then
    reader.setup {
        autostart = false,
        speed = 260,
    }
end
