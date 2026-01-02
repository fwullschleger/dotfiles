-- Audio Switcher for Hammerspoon

-- ============================================
-- Configuration: Add your favorite devices here
-- ============================================
local favoriteDevices = {
    { key = '0', name = "MacBook Pro Speakers" },
    { key = '8', name = "AirPods Pro Operator" },
    { key = '9', name = "Jabra Evolve 65" },
}

-- ============================================
-- Core Functions
-- ============================================

local function findDeviceByName(searchName)
    local devices = hs.audiodevice.allOutputDevices()
    for _, device in ipairs(devices) do
        -- Partial match (case-insensitive)
        if string.find(string.lower(device:name()), string.lower(searchName)) then
            return device
        end
    end
    return nil
end

local function switchToDevice(deviceName)
    local device = findDeviceByName(deviceName)
    if device then
        device:setDefaultOutputDevice()
        device:setOutputMuted(false)
        hs.alert('🔊 ' .. device:name())
    else
        hs.alert('⚠️ Device not found: ' .. deviceName)
    end
end

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

local function handleAudioChoice(choice)
    if not choice then return end

    local device = hs.audiodevice.findDeviceByUID(choice['uuid'])
    device:setDefaultOutputDevice()
    device:setOutputMuted(false)

    hs.alert('🔊 ' .. device:name())
end

-- ============================================
-- Hotkey Bindings
-- ============================================

-- Chooser dialog
local audioChooser = hs.chooser.new(handleAudioChoice)
audioChooser:width(40)

hs.hotkey.bind(hyper, '7', "Audio Switcher", function()
    audioChooser:choices(getDeviceChoices())
    audioChooser:show()
end)

-- Direct device switching
for _, fav in ipairs(favoriteDevices) do
    hs.hotkey.bind(hyper, fav.key, "Switch to " .. fav.name, function()
        switchToDevice(fav.name)
    end)
end
