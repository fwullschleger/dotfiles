-- Startup notification
hs.notify.show("Hammerspoon", "Started", hs.screen.mainScreen():name())

-- Hyper key (configure with Karabiner Elements or similar)
hyper = { "shift", "ctrl", "alt", "cmd" }

-- Quality settings
hs.window.animationDuration = 0.1  -- Faster window animations
hs.hotkey.alertDuration = 0        -- Disable hotkey alert popups

-- Load audio switcher
require('audio-switcher')