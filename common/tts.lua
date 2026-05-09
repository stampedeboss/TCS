---------------------------------------------------------------------
-- TCS COMMON: TEXT TO SPEECH (TTS)
-- Integrates MSRS and STTS for dynamic voice generation over SRS.
---------------------------------------------------------------------
env.info("TCS(COMMON.TTS): loading")

TCS = TCS or {}
TCS.AWACS = TCS.AWACS or {}

local AWACS_ENGINE = nil

function TCS.AWACS.Setup()
    local cfg = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.TTS
    if not cfg then return end

    local coal = TCS.Common.Defaults.Coalition or coalition.side.BLUE

    if _G.MSRS then
        if not os or not os.execute then
            env.error("TCS(TTS): os.execute is missing! TTS will fail. Please desanitize MissionScripting.lua.")
        end

        -- Auto-detect opusenc.exe
        local function findOpus(p)
            if not p then return nil end
            if lfs and lfs.attributes(p .. "\\opusenc.exe") then return p end
            if lfs and lfs.attributes(p .. "\\Server\\opusenc.exe") then return p .. "\\Server" end
            if lfs and lfs.attributes(p .. "\\ExternalAudio\\opusenc.exe") then return p .. "\\ExternalAudio" end
            if lfs and lfs.attributes(p .. "\\Client\\opusenc.exe") then return p .. "\\Client" end
            return nil
        end

        local found = findOpus(cfg.SRSPath) or findOpus([[C:\Program Files\DCS-SimpleRadio-Standalone]]) or findOpus([[C:\Program Files (x86)\DCS-SimpleRadio-Standalone]])
        
        if found then
            AWACS_ENGINE = MSRS:New(found, cfg.Freq, cfg.Mod)
            AWACS_ENGINE:SetCoalition(coal)
            AWACS_ENGINE:SetPort(cfg.Port or 5002)
            AWACS_ENGINE:SetLabel(cfg.Label or "MAGIC")
            AWACS_ENGINE:SetCulture(cfg.Culture or "en-US")
            AWACS_ENGINE:SetGender(cfg.Gender or "male")
            AWACS_ENGINE:SetVolume(1.0)
            env.info("TCS(TTS): MSRS TTS is enabled on " .. tostring(cfg.Freq) .. " MHz.")
        else
            env.error("TCS(TTS): opusenc.exe NOT FOUND. MSRS TTS will fail.")
        end
    elseif _G.STTS then
        if cfg.Port then STTS.SRS_PORT = cfg.Port end
        env.info("TCS(TTS): STTS found. Using standalone SRS TTS.")
    end
end

-- Legacy F10 Trigger compatibility
_G.SetupAwacs = TCS.AWACS.Setup

function TCS.AWACS.Say(text)
    if not text then return end
    local ttsText = text:gsub("\n", ". ")

    if AWACS_ENGINE then
        local status, err = pcall(function() AWACS_ENGINE:PlayText(ttsText, 0) end)
        if not status then env.error("TCS(TTS): MSRS PlayText failed: " .. tostring(err)) end
    elseif _G.STTS then
        local cfg = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.TTS
        local coal = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.Coalition or coalition.side.BLUE
        if cfg then
            local status, err = pcall(function() 
                STTS.TextToSpeech(ttsText, {cfg.Freq}, cfg.Mod, 1.0, cfg.Label or "MAGIC", coal, nil, 1.0, cfg.Gender or "male", cfg.Culture or "en-US") 
            end)
            if not status then env.error("TCS(TTS): STTS TextToSpeech failed: " .. tostring(err)) end
        end
    end
end

function TCS.AWACS.TestTTS(text)
    local cfg = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.TTS
    local label = cfg and cfg.Label or "MAGIC"
    local phrase = text or "This is a test of the text to speech system."
    TCS.AWACS.Say(string.format("%s. %s", label, phrase))
end

function TCS.AWACS.DispatchNATO(group, playerUnit, targetCoord, descriptor, tail)
    local cfg = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.TTS
    local label = cfg and cfg.Label or "MAGIC"
    if not group or not playerUnit or not playerUnit:IsAlive() or not targetCoord then return end
    
    local bull = _G.NATO_BULLSEYE and _G.NATO_BULLSEYE(targetCoord) or "BRAA"
    local t = tail or "SURFACE"
    local phrase = string.format("%s. %s. %s. %s.", label, descriptor, bull, t)
    
    TCS.AWACS.Say(phrase)
    if TCS.MsgToGroup then TCS.MsgToGroup(group, label .. ": " .. descriptor .. " | " .. bull .. " | " .. t, 12) end
end

---------------------------------------------------------------------
-- A2G AWACS Interface Port
---------------------------------------------------------------------
TCS.A2G = TCS.A2G or {}
TCS.A2G.AWACS = {}
function TCS.A2G.AWACS:AssignBAI(group, anchor, echelon)
    local unit = group and group.GetUnit and group:GetUnit(1)
    if unit and anchor then TCS.AWACS.DispatchNATO(group, unit, anchor, "BAI TASKING", "ENGAGE") end
end

env.info("TCS(COMMON.TTS): ready")