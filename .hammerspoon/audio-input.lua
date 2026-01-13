-- Audio Input (Microphone) Switcher for Hammerspoon
-- Exports functions to be called from main eventtap in init.lua

local M = {}

-- ============================================
-- Configuration
-- ============================================
local chooserKey = "z"
local muteKey = "d"

local inputDevices = {
    ["o"] = "MacBook Pro Microphone",
    ["u"] = "AirPods Pro Operator",
    ["i"] = "Jabra Evolve 65",
}

-- ============================================
-- Core Functions
-- ============================================

local function findDeviceByName(searchName)
    local devices = hs.audiodevice.allInputDevices()
    for _, device in ipairs(devices) do
        if string.find(string.lower(device:name()), string.lower(searchName)) then
            return device
        end
    end
    return nil
end

function M.switchToDevice(deviceName)
    local device = findDeviceByName(deviceName)
    if device then
        device:setDefaultInputDevice()
        device:setInputMuted(false)
        hs.alert('🎤 ' .. device:name())
    else
        hs.alert('⚠️ Microphone not found: ' .. deviceName)
    end
end

function M.muteInput()
    local device = hs.audiodevice.defaultInputDevice()
    if device then
        local muted = device:inputMuted()
        device:setInputMuted(not muted)
        if muted then
            hs.alert('🎤 Microphone Unmuted')
        else
            hs.alert('🎙️ Microphone Muted')
        end
    end
end

-- ============================================
-- Chooser
-- ============================================

local function getDeviceChoices()
    local devices = hs.audiodevice.allInputDevices()
    local choices = {}
    local currentUid = hs.audiodevice.current(true).uid

    for i, device in ipairs(devices) do
        local icon = device:inputMuted() and '🔇' or '🎤'
        local subText = icon

        if device:inputVolume() then
            subText = subText .. ' Volume ' .. math.floor(device:inputVolume()) .. '%'
        end

        choices[i] = {
            text = (currentUid == device:uid() and "➜ " or "    ") .. device:name(),
            subText = "    " .. subText,
            uuid = device:uid(),
        }
    end

    return choices
end

local function handleChoice(choice)
    if not choice then return end

    local device = hs.audiodevice.findDeviceByUID(choice['uuid'])
    if device then
        device:setDefaultInputDevice()
        device:setInputMuted(false)
        hs.alert('🎤 ' .. device:name())
    end
end

local inputChooser = hs.chooser.new(handleChoice)
inputChooser:width(40)

function M.showChooser()
    inputChooser:choices(getDeviceChoices())
    inputChooser:show()
end

-- ============================================
-- Hotkey Bindings
-- ============================================

function M.bindHotkeys()
    local hyper = {"cmd", "alt", "shift", "ctrl"}

    -- Microphone Chooser
    hs.hotkey.bind(hyper, chooserKey, function()
        M.showChooser()
    end)

    -- Mute/Unmute
    hs.hotkey.bind(hyper, muteKey, function()
        M.muteInput()
    end)

    -- Bind each configured input device
    for key, deviceName in pairs(inputDevices) do
        hs.hotkey.bind(hyper, key, function()
            M.switchToDevice(deviceName)
        end)
    end
end

return M