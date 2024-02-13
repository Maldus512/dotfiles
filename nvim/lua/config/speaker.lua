local status, speak = pcall(require, "speak")
if status then
    speak.setup {
        autostart = false,
        speed = 260,
    }
end
