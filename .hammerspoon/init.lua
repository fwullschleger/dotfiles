-- Hammerspoon Configuration

-- Startup notification
hs.notify.show("Hammerspoon", "Started", hs.screen.mainScreen():name())

-- Quality settings
hs.window.animationDuration = 0.1
hs.hotkey.alertDuration = 0

-- ============================================
-- Load and Initialize Audio Modules
-- ============================================
local audioOutput = require('audio-output')
local audioInput = require('audio-input')

-- Bind hotkeys for each module
audioOutput.bindHotkeys()
audioInput.bindHotkeys()

-- -- ============================================
-- -- SpoonInstall
-- -- ============================================
-- hs.loadSpoon("SpoonInstall")
-- 
-- spoon.SpoonInstall.repos.PaperWM = {
--     url = "https://github.com/mogenson/PaperWM.spoon",
--     desc = "PaperWM.spoon repository",
--     branch = "release",
-- }
-- 
-- spoon.SpoonInstall:andUse("PaperWM", {
--     repo = "PaperWM",
--     config = { screen_margin = 16, window_gap = 2 },
--     start = true,
-- })
-- 
-- -- ============================================
-- -- PaperWM
-- -- ============================================
-- PaperWM = hs.loadSpoon("PaperWM")
-- PaperWM:bindHotkeys({
--     -- focus windows (matches aerospace: alt-hjkl)
--     focus_left  = {{"alt"}, "h"},
--     focus_right = {{"alt"}, "l"},
--     focus_up    = {{"alt"}, "k"},
--     focus_down  = {{"alt"}, "j"},
-- 
--     -- move windows (matches aerospace: alt-shift-hjkl)
--     swap_left  = {{"alt", "shift"}, "h"},
--     swap_right = {{"alt", "shift"}, "l"},
--     swap_up    = {{"alt", "shift"}, "k"},
--     swap_down  = {{"alt", "shift"}, "j"},
-- 
--     -- resize (matches aerospace: alt-shift-minus/equal)
--     decrease_width = {{"alt", "shift"}, "-"},
--     increase_width = {{"alt", "shift"}, "="},
-- 
--     -- fullscreen (matches aerospace: alt-ctrl-shift-f)
--     full_width = {{"alt", "ctrl", "shift"}, "f"},
-- 
--     -- toggle floating/tiling (matches aerospace: alt-ctrl-f)
--     toggle_floating = {{"alt", "ctrl"}, "f"},
-- 
--     -- PaperWM-specific: cycle width/height
--     cycle_width          = {{"alt"}, "r"},
--     reverse_cycle_width  = {{"alt", "ctrl"}, "r"},
--     cycle_height         = {{"alt", "shift"}, "r"},
--     reverse_cycle_height = {{"alt", "ctrl", "shift"}, "r"},
-- 
--     -- PaperWM-specific: layout helpers
--     center_window  = {{"alt"}, "c"},
--     slurp_in       = {{"alt"}, "i"},
--     barf_out       = {{"alt"}, "o"},
--     split_screen   = {{"alt"}, "s"},
--     focus_floating = {{"alt", "shift"}, "f"},
-- 
--     -- cycle focus forward/backward through window strip
--     focus_prev = {{"alt"}, ","},
--     focus_next = {{"alt"}, "."},
-- 
--     -- focus window by position (alt-1..9, most frequent action)
--     focus_window_1 = {{"alt"}, "1"},
--     focus_window_2 = {{"alt"}, "2"},
--     focus_window_3 = {{"alt"}, "3"},
--     focus_window_4 = {{"alt"}, "4"},
--     focus_window_5 = {{"alt"}, "5"},
--     focus_window_6 = {{"alt"}, "6"},
--     focus_window_7 = {{"alt"}, "7"},
--     focus_window_8 = {{"alt"}, "8"},
--     focus_window_9 = {{"alt"}, "9"},
-- 
--     -- switch space (alt-ctrl-1..9, less frequent context switches)
--     switch_space_l = {{"alt", "ctrl"}, "h"},
--     switch_space_r = {{"alt", "ctrl"}, "l"},
--     switch_space_1 = {{"alt", "ctrl"}, "1"},
--     switch_space_2 = {{"alt", "ctrl"}, "2"},
--     switch_space_3 = {{"alt", "ctrl"}, "3"},
--     switch_space_4 = {{"alt", "ctrl"}, "4"},
--     switch_space_5 = {{"alt", "ctrl"}, "5"},
--     switch_space_6 = {{"alt", "ctrl"}, "6"},
--     switch_space_7 = {{"alt", "ctrl"}, "7"},
--     switch_space_8 = {{"alt", "ctrl"}, "8"},
--     switch_space_9 = {{"alt", "ctrl"}, "9"},
-- 
--     -- move window to space (alt-shift-1..9)
--     move_window_1 = {{"alt", "shift"}, "1"},
--     move_window_2 = {{"alt", "shift"}, "2"},
--     move_window_3 = {{"alt", "shift"}, "3"},
--     move_window_4 = {{"alt", "shift"}, "4"},
--     move_window_5 = {{"alt", "shift"}, "5"},
--     move_window_6 = {{"alt", "shift"}, "6"},
--     move_window_7 = {{"alt", "shift"}, "7"},
--     move_window_8 = {{"alt", "shift"}, "8"},
--     move_window_9 = {{"alt", "shift"}, "9"},
-- })
-- PaperWM:start()

-- Log successful load
print("Hammerspoon configuration loaded")