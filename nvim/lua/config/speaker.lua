local status, speaker = pcall(require, "speaker")
if status then
    speaker.setup {
        autostart = false,
        speed = 260,
    }
end
