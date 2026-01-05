-- Hammerspoon Configuration
-- Hyper + A layer using eventtap for three-key combinations

-- Startup notification
hs.notify.show("Hammerspoon", "Started", hs.screen.mainScreen():name())

-- Quality settings
hs.window.animationDuration = 0.1
hs.hotkey.alertDuration = 0

-- ============================================
-- Load Modules
-- ============================================
local audioOutput = require('audio-output')
local audioInput = require('audio-input')

-- ============================================
-- Key Code Mappings (German QWERTZ layout)
-- ============================================
local keyCodes = {
    -- Letters
    a = 0,
    s = 1,
    d = 2,
    z = 6,   -- German Z (position of US Y)
    u = 32,
    i = 34,
    o = 31,
    m = 46,
    -- Numbers
    ["7"] = 26,
    ["8"] = 28,
    ["9"] = 25,
    ["0"] = 29,
    -- Punctuation
    [","] = 43,
    ["."] = 47,
}

-- Reverse lookup: keyCode -> character
local keyCodeToChar = {}
for char, code in pairs(keyCodes) do
    keyCodeToChar[code] = char
end

-- ============================================
-- Hyper + A Layer Eventtap
-- ============================================

-- Track whether A key is currently held
local aKeyHeld = false
local aKeyDownTime = 0

-- Store reference globally to prevent garbage collection
local hyperALayerTap

local function handleEvent(event)
    local keyCode = event:getKeyCode()
    local eventType = event:getType()
    local flags = event:getFlags()

    -- Check if Hyper is held (cmd + alt + shift + ctrl)
    local hyperHeld = flags.cmd and flags.alt and flags.shift and flags.ctrl

    -- Reset aKeyHeld if Hyper is not held (prevents stuck state)
    if not hyperHeld then
        aKeyHeld = false
        return false
    end

    -- Track A key state when Hyper is held
    if keyCode == keyCodes.a then
        if eventType == hs.eventtap.event.types.keyDown then
            aKeyHeld = true
            aKeyDownTime = hs.timer.secondsSinceEpoch()
        elseif eventType == hs.eventtap.event.types.keyUp then
            aKeyHeld = false
        end
        return false
    end

    -- Safety: Reset if A has been "held" for more than 10 seconds (stuck state)
    if aKeyHeld and (hs.timer.secondsSinceEpoch() - aKeyDownTime) > 10 then
        aKeyHeld = false
        return false
    end

    -- Handle action keys when Hyper + A is held
    if eventType == hs.eventtap.event.types.keyDown and aKeyHeld then
        local keyChar = keyCodeToChar[keyCode]

        if keyChar then
            -- Try each module's handler
            if audioOutput.handleKey(keyChar) then
                return true
            end
            if audioInput.handleKey(keyChar) then
                return true
            end
        end
    end

    return false
end

-- Wrap handler in pcall to prevent errors from stopping the eventtap
local function safeHandleEvent(event)
    local success, result = pcall(handleEvent, event)
    if not success then
        print("Hyper+A layer error: " .. tostring(result))
        return false
    end
    return result
end

hyperALayerTap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp },
    safeHandleEvent
)

hyperALayerTap:start()

-- Watchdog timer: Re-enable eventtap if it gets disabled
local watchdog = hs.timer.new(5, function()
    if hyperALayerTap and not hyperALayerTap:isEnabled() then
        print("Hyper+A layer was disabled, re-enabling...")
        hyperALayerTap:start()
    end
end)
watchdog:start()

-- Log successful load
print("Hyper + A layer initialized")