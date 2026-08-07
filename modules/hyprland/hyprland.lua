-- See https://wiki.hyprland.org/Configuring/Keywords/
-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.exec_cmd(ssh_menu))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + END", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.window.cycle_next({ next = true }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.layout("togglesplit"))

-- Screen-lock
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(hyprlock))

-- Move focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- Monitoring workspace
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("monitoring"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:monitoring", follow = false }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp -o)\" - | swappy -f -"))

-- Set floating and pinned
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.float({ action = "set" }))
hl.bind(mainMod .. " + SHIFT + P", function() local m = hl.get_active_monitor(); if not m then return end; hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width * 25 / 100), y = math.floor(m.height * 35 / 100) })) end)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())

-- Popup pinned terminal
hl.bind(mainMod .. " + CTRL + return", hl.dsp.exec_cmd("[float; size (monitor_w/2) (monitor_h/4); move ((monitor_w/2)-window_w) 30; pin] " .. terminal))

-- Media controls
hl.bind("XF86AudioStop", hl.dsp.exec_cmd(playerctl .. " stop"), { repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(playerctl .. " play-pause"), { repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(playerctl .. " next"), { repeating = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(playerctl .. " previous"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(wpctl .. " set-volume @DEFAULT_SINK@ 2%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(wpctl .. " set-volume @DEFAULT_SINK@ 2%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(wpctl .. " set-mute @DEFAULT_SINK@ toggle"), { repeating = true })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Monitor config
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = "1.2", })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto", })
hl.monitor({ output = "Unknown-1", disabled = true, })

-- Do not listen to maximize events from applications
hl.window_rule({ match = { class = ".*", }, suppress_event = "maximize", })

-- Keep Rofi in focus when it's open
hl.window_rule({ match = { title = ".*(rofi).*", }, stay_focused = true, })

-- Disable gaps on workspaces with only a single window
hl.window_rule({ match = { float = 0, workspace = "w[tv1]", }, border_size = 0, rounding = 0, })
hl.window_rule({ match = { float = 0, workspace = "f[1]", }, border_size = 0, rounding = 0, })
hl.window_rule({ match = { pin = 1, }, border_color = "rgb(FF0000)", })
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0, })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0, })

-- Resize windows
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind(mainMod .. " + h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

    hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -200, y = 0, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 200, y = 0, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -200, relative = true }), { repeating = true })
    hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 200, relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)



hl.on("hyprland.start", function()
    hl.exec_cmd(start_hyperland)
    hl.exec_cmd(terminal)
    hl.exec_cmd(terminal .. " " .. btop, { workspace = "special:monitoring silent" })
    hl.exec_cmd(terminal .. " nvtop", { workspace = "special:monitoring silent" })
end)
