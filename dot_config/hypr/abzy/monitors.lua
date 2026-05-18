local laptopMonitor = "eDP-1"
local homeMonitor = "DP-1"
local officeMonitor = "DP-5"

hl.monitor({
    output = laptopMonitor,
    mode = "1920x1080@60",
    position = "auto-left",
    scale = 1.25
})

hl.monitor({
    output = homeMonitor,
    mode = "2560x1440@180.06",
    position = "0x0",
    scale = 1
})

hl.monitor({
    output = officeMonitor,
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1
})
