-- Audio Output Switcher for Hammerspoon
-- Exports functions to be called from main eventtap in init.lua

local M = {}

-- ============================================
-- Configuration
-- ============================================
local chooserKey = "7"

local outputDevices = {
    ["0"] = "MacBook Pro Speakers",
    ["8"] = "AirPods Pro Operator",
    ["9"] = "Jabra Evolve 65",
}

-- ============================================
-- Core Functions
-- ============================================

local function findDeviceByName(searchName)
    local devices = hs.audiodevice.allOutputDevices()
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
        device:setDefaultOutputDevice()
        device:setOutputMuted(false)
        hs.alert('🔊 ' .. device:name())
    else
        hs.alert('⚠️ Output device not found: ' .. deviceName)
    end
end

function M.muteOutput()
    local device = hs.audiodevice.defaultOutputDevice()
    if device then
        local muted = device:outputMuted()
        device:setOutputMuted(not muted)
        if muted then
            hs.alert('🔊 Output Unmuted')
        else
            hs.alert('🔇 Output Muted')
        end
    end
end

-- ============================================
-- Chooser
-- ============================================

local function getDeviceChoices()
    local devices = hs.audiodevice.allOutputDevices()
    local choices = {}
    local currentUid = hs.audiodevice.current(false).uid

    for i, device in ipairs(devices) do
        local icon = device:outputMuted() and '🔇' or '🔊'
        local subText = icon

        if device:outputVolume() then
            subText = subText .. ' Volume ' .. math.floor(device:outputVolume()) .. '%'
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
        device:setDefaultOutputDevice()
        device:setOutputMuted(false)
        hs.alert('🔊 ' .. device:name())
    end
end

local outputChooser = hs.chooser.new(handleChoice)
outputChooser:width(40)

function M.showChooser()
    outputChooser:choices(getDeviceChoices())
    outputChooser:show()
end

-- ============================================
-- Hotkey Bindings
-- ============================================

function M.bindHotkeys()
    local hyper = {"cmd", "alt", "shift", "ctrl"}

    -- Device Chooser
    hs.hotkey.bind(hyper, chooserKey, function()
        M.showChooser()
    end)

    -- Bind each configured output device
    for key, deviceName in pairs(outputDevices) do
        hs.hotkey.bind(hyper, key, function()
            M.switchToDevice(deviceName)
        end)
    end
end

return M