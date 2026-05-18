local mainMod = "SUPER"

local function kb(parts)
	return table.concat(parts, " + ")
end

hl.bind(kb({ mainMod, "Q" }), hl.dsp.exec_cmd("ghostty +new-window"))
hl.bind(kb({ mainMod, "C" }), hl.dsp.window.close())
hl.bind(kb({ mainMod, "SHIFT", "M" }), hl.dsp.exit())
hl.bind(
	kb({ mainMod, "V" }),
	hl.dsp.exec_cmd("clipvault list | rofi -dmenu -display-columns 2 | clipvault get | wl-copy")
)
hl.bind(kb({ mainMod, "E" }), hl.dsp.exec_cmd(DefaultApps.fileManager))
hl.bind(kb({ mainMod, "L" }), hl.dsp.exec_cmd("hyprlock"))
hl.bind(kb({ mainMod, "CONTROL", "SPACE" }), hl.dsp.window.float({ action = "toggle" }))
hl.bind(kb({ mainMod, "D" }), hl.dsp.exec_cmd(DefaultApps.menu))
hl.bind(kb({ mainMod, "W" }), hl.dsp.exec_cmd(DefaultApps.windowMenu))
hl.bind(kb({ mainMod, "G" }), hl.dsp.exec_cmd(DefaultApps.sshMenu))
hl.bind(kb({ mainMod, "SHIFT", "S" }), hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(kb({ mainMod, "CONTROL", "SHIFT", "S" }), hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(kb({ mainMod, "S" }), hl.dsp.exec_cmd('grim -g "$(slurp -o)" - | wl-copy'))
hl.bind(kb({ mainMod, "F" }), hl.dsp.window.fullscreen())
hl.bind(kb({ mainMod, "B" }), hl.dsp.exec_cmd("rofimoji --action copy"))
hl.bind(kb({ mainMod, "SHIFT", "C" }), hl.dsp.exec_cmd("hyprpicker | wl-copy"))
hl.bind(kb({ mainMod, "CONTROL", "SHIFT", "R" }), hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(kb({ mainMod, "left" }), hl.dsp.focus({ direction = "left" }))
hl.bind(kb({ mainMod, "right" }), hl.dsp.focus({ direction = "right" }))
hl.bind(kb({ mainMod, "up" }), hl.dsp.focus({ direction = "up" }))
hl.bind(kb({ mainMod, "down" }), hl.dsp.focus({ direction = "down" }))
for i = 1, 9, 1 do
	hl.bind(kb({ mainMod, i }), hl.dsp.focus({ workspace = i }))
	hl.bind(kb({ mainMod, "SHIFT", i }), hl.dsp.window.move({ workspace = i }))
end
hl.bind(kb({ mainMod, 0 }), hl.dsp.focus({ workspace = 10 }))
hl.bind(kb({ mainMod, "SHIFT", 0 }), hl.dsp.window.move({ workspace = 10 }))

hl.bind(kb({ mainMod, "CONTROL", "left" }), hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(kb({ mainMod, "CONTROL", "right" }), hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(kb({ mainMod, "CONTROL", "up" }), hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(kb({ mainMod, "CONTROL", "down" }), hl.dsp.workspace.move({ monitor = "d" }))

hl.bind(kb({ mainMod, "SHIFT", "left" }), hl.dsp.window.move({ direction = "l" }))
hl.bind(kb({ mainMod, "SHIFT", "right" }), hl.dsp.window.move({ direction = "r" }))
hl.bind(kb({ mainMod, "SHIFT", "up" }), hl.dsp.window.move({ direction = "u" }))
hl.bind(kb({ mainMod, "SHIFT", "down" }), hl.dsp.window.move({ direction = "d" }))

hl.bind(kb({ mainMod, "ALT", "R" }), hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("left", hl.dsp.window.resize({ x = -25, y = 0 }))
	hl.bind("right", hl.dsp.window.resize({ x = 25, y = 0 }))
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -25 }))
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 25 }))

	hl.bind("ESCAPE", hl.dsp.submap("reset"))
end)

hl.bind(kb({ mainMod, "comma" }), hl.dsp.layout("cycleprev"))
hl.bind(kb({ mainMod, "period" }), hl.dsp.layout("cyclenext"))

hl.bind(kb({ mainMod, "SHIFT", "minus" }), hl.dsp.exec_cmd("notify-send \"" .. hl.get_active_window().title .. "\""))
hl.bind(kb({ mainMod, "SHIFT", "equal" }), hl.dsp.exec_cmd("notify-send \"" .. hl.get_active_window().title .. "\""))

hl.bind(kb({ mainMod, "minus" }), hl.dsp.focus({ workspace = "-1" }))
hl.bind(kb({ mainMod, "equal" }), hl.dsp.focus({ workspace = "+1" }))

hl.bind(kb({ mainMod, "mouse:272" }), hl.dsp.window.drag(), { mouse = true })
hl.bind(kb({ mainMod, "mouse:273" }), hl.dsp.window.resize(), { mouse = true })

hl.bind(kb({ "XF86PowerOff" }), hl.dsp.exec_cmd("wlogout"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))
-- TODO: make it generic or move to host specific file
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight s +1"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight s 1-"))
hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl aura -n"))
hl.bind(
	"XF86Launch4",
	hl.dsp.exec_cmd(
		'asusctl profile -n && notify-send -r 57705 "Profile: $(asusctl profile --profile-get | grep -oP "is \\K.*")" -a asusctl'
	)
)
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("~/.local/bin/toggleTouchpad"))

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
