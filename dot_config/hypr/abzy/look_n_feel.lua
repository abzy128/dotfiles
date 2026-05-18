hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 2,

		col = {
			active_border = "0xffdcd7ba",
			inactive_border = "0xff595959",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "monocle",
	},
	scrolling = {
		direction = "right",
		column_width = 1.0,
	},
	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		blur = {
			enabled = false,
		},
		shadow = {
			enabled = false,
		},
	},
	animations = {
		enabled = 1,
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
	},
	xwayland = {
		force_zero_scaling = true,
	},
	ecosystem = {
		no_update_news = true,
	},
})

-- Animations
hl.curve("easeInAndOut", { type = "bezier", points = { { 0.83, 0 }, { 0.17, 1 } } })
hl.curve("defaultSpring", { type = "spring", mass = 1, stiffness = 250, dampening = 35 })
hl.animation({ leaf = "global", enabled = true, speed = 2, spring = "defaultSpring" })
--hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "easeInAndOut" })
