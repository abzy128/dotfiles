hl.window_rule({
	match = {
		class = "^(org.telegram.desktop)$",
		title = "^(Media viewer)$",
	},
	fullscreen = true,
	workspace = "unset",
})

hl.window_rule({ match = { title = "^(Open)$" }, float = true })
hl.window_rule({ match = { title = "^(Choose File)$" }, float = true })
hl.window_rule({ match = { title = "^(Save As)$" }, float = true })

hl.window_rule({
	name = "kde file picker",
	match = {
		class = "org.freedesktop.impl.portal.desktop.kde",
	},
	float = true,
	center = true,
	size = "1000 600",
})

hl.window_rule({ match = { title = "^(Confirm to replace files)$" }, float = true })
hl.window_rule({ match = { title = "^(File Operation Progress)$" }, float = true })
hl.window_rule({ match = { class = "^(google-chrome)$", title = "^(Open File)$" }, float = true })
--hl.window_rule({ match = { title = "Bitwarden" }, float = true })

hl.window_rule({
	name = "pavucontrol",
	match = {
		class = "org.pulseaudio.pavucontrol",
	},
	float = true,
	center = true,
	size = "1000 600",
})

-- Bitwarden extension in Chromium
--hl.window_rule({ match = { title = "(.*nngceckbapebfimnlniiiahkandclblb.*)" }, float = true })

-- # Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({ match = { class = "(pinentry-)(.*)" }, stay_focused = true })

hl.window_rule({ match = { class = "zoom", title = "annotate_toolbar" }, float = true, workspace = "silent" })

