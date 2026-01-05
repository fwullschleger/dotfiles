-- Media Controls for Hammerspoon
-- Exports functions to be called from main eventtap in init.lua

local M = {}

-- ============================================
-- Media Key Functions using System Key Events
-- ============================================

local function sendSystemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

function M.playPause()
    sendSystemKey("PLAY")
    hs.alert('⏯️ Play/Pause')
end

function M.previousTrack()
    sendSystemKey("PREVIOUS")
    hs.alert('⏮️ Previous Track')
end

function M.nextTrack()
    sendSystemKey("NEXT")
    hs.alert('⏭️ Next Track')
end

-- ============================================
-- Mute Functions (delegate to audio modules)
-- ============================================

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
-- Action Handler (called from eventtap)
-- ============================================

function M.handleKey(keyChar)
    if keyChar == "s" then
        M.playPause()
        return true
    elseif keyChar == "," then
        M.previousTrack()
        return true
    elseif keyChar == "." then
        M.nextTrack()
        return true
    elseif keyChar == "m" then
        M.muteOutput()
        return true
    elseif keyChar == "d" then
        M.muteInput()
        return true
    end

    return false
end

return M