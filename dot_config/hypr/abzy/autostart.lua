hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	--hl.exec_cmd("dunst")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("udiskie")
	hl.exec_cmd("poweralertd")
	-- hl.exec_cmd("hyprlauncher -d")
	hl.exec_cmd("noctalia")
	--hl.exec_cmd("hyprmoncfgd")

	-- TODO: add check for if device is ASUS ROG device. if so exec "rog-control-center"
end)
