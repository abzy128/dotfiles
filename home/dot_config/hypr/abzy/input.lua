hl.config({
    cursor = {
        no_hardware_cursors = true
    },
    input = {
        kb_layout = "us,ru,kz",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle,compose:caps",
        kb_rules = "",
        numlock_by_default = true,
        follow_mouse = 2,
        sensitivity = -0.2,
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.5
        }
    }
})

hl.gesture({fingers = 3, direction = "horizontal", action = "workspace"})

-- For disabling touchpad 
-- hl.device({
--     enabled = true,
--     name = "asuf1205:00-2808:0106-touchpad",
--     sensitivity = 0
-- })