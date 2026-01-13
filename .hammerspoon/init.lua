-- Hammerspoon Configuration

-- Startup notification
hs.notify.show("Hammerspoon", "Started", hs.screen.mainScreen():name())

-- Quality settings
hs.window.animationDuration = 0.1
hs.hotkey.alertDuration = 0

-- ============================================
-- Load and Initialize Modules
-- ============================================
local audioOutput = require('audio-output')
local audioInput = require('audio-input')

-- Bind hotkeys for each module
audioOutput.bindHotkeys()
audioInput.bindHotkeys()

-- Log successful load
print("Hammerspoon configuration loaded")