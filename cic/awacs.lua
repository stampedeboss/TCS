---------------------------------------------------------------------
-- TCS CIC: AWACS
-- Command and Control interface for Airborne Warning and Control.
---------------------------------------------------------------------
env.info("TCS(CIC.AWACS): loading")

local AWACS = nil

TCS.CIC = TCS.CIC or {}
TCS.CIC.AWACS = {}

-- Ensure we reference the correct config
local function GetCfg() return TCS.Signals and TCS.Signals.Config end

function SetupAwacs()
  local CFG = GetCfg()
  if not CFG or not CFG.AWACS then
    env.error("TCS(CIC.AWACS): TCS.Signals.Config.AWACS table not found! TTS will not be configured.")
    return
  end
  env.info(string.format("TCS(CIC.AWACS): Config found. Freq: %.3f, Mod: %d, Label: %s", CFG.AWACS.Freq, CFG.AWACS.Mod, CFG.AWACS.Label))

  local coal = CFG.Coalition or (TCS.Air and TCS.Air.Config and TCS.Air.Config.Coalition) or coalition.side.BLUE
  local bull = TCS.ResolveBullseye()
  if not bull then
    MESSAGE:New("WARNING: No Bullseye found. Please set a Bullseye for the BLUE coalition in the Mission Editor. Bullseye calls will be unavailable.", 15)
      :ToCoalition(coal)
  end

  if _G.MSRS then
    if not os or not os.execute then
      env.error("TCS(CIC.AWACS): os.execute is missing! TTS will fail. Please desanitize MissionScripting.lua.")
    end

    -- Auto-detect opusenc.exe location if not found in root
    if lfs then
      local function findOpus(p)
        if not p then return nil end
        if lfs.attributes(p .. "\\opusenc.exe") then return p end
        if lfs.attributes(p .. "\\Server\\opusenc.exe") then return p .. "\\Server" end
        if lfs.attributes(p .. "\\ExternalAudio\\opusenc.exe") then return p .. "\\ExternalAudio" end
        if lfs.attributes(p .. "\\Client\\opusenc.exe") then return p .. "\\Client" end
        return nil
      end

      local found = findOpus(CFG.AWACS.SRSPath)
      if not found then found = findOpus([[C:\Program Files\DCS-SimpleRadio-Standalone]]) end
      if not found then found = findOpus([[C:\Program Files (x86)\DCS-SimpleRadio-Standalone]]) end

      if found then
        if found ~= CFG.AWACS.SRSPath then
           env.warning("TCS(CIC.AWACS): Auto-corrected SRSPath to " .. found)
           CFG.AWACS.SRSPath = found
        end
      else
        env.error("TCS(CIC.AWACS): opusenc.exe NOT FOUND. TTS will fail.")
        env.error("TCS(CIC.AWACS): Please download 'opus-tools' and place 'opusenc.exe' in: " .. CFG.AWACS.SRSPath)
      end
    end

    AWACS = MSRS:New(CFG.AWACS.SRSPath, CFG.AWACS.Freq, CFG.AWACS.Mod)
    AWACS:SetCoalition(coal)
    AWACS:SetPort(CFG.AWACS.Port or 5002)
    AWACS:SetLabel(CFG.AWACS.Label)
    AWACS:SetCulture(CFG.AWACS.Culture or "en-US")
    AWACS:SetGender(CFG.AWACS.Gender or "male")
    AWACS:SetVolume(1.0)
    env.info("TCS(CIC.AWACS): MSRS TTS is enabled.")
  elseif _G.STTS then
    if CFG.AWACS.Port then STTS.SRS_PORT = CFG.AWACS.Port end
    env.info("TCS(CIC.AWACS): STTS found. Using standalone SRS TTS.")
  else
    MESSAGE:New("WARNING: MSRS/STTS not found. Voice calls disabled (text backup still works).", 15)
      :ToCoalition(coal)
  end
end

local function _say(text)
  if not text then return end
  -- Sanitize for TTS: replace newlines with period+space to ensure continuity
  local ttsText = text:gsub("\n", ". ")

  if AWACS then
    local status, err = pcall(function() AWACS:PlayText(ttsText, 0) end)
    if not status then env.error("TCS(CIC.AWACS): MSRS PlayText failed: " .. tostring(err)) end
  elseif _G.STTS then
    local CFG = GetCfg()
    local coal = CFG.Coalition or (TCS.Air and TCS.Air.Config and TCS.Air.Config.Coalition) or coalition.side.BLUE
    local status, err = pcall(function() 
      STTS.TextToSpeech(ttsText, {CFG.AWACS.Freq}, CFG.AWACS.Mod, 1.0, CFG.AWACS.Label, coal, nil, 1.0, CFG.AWACS.Gender or "male", CFG.AWACS.Culture or "en-US") 
    end)
    if not status then env.error("TCS(CIC.AWACS): STTS TextToSpeech failed: " .. tostring(err)) end
  end
end

function TCS.CIC.AWACS.Say(text)
  _say(text)
end

function TCS.CIC.AWACS.TestTTS(text)
  local CFG = GetCfg()
  local label = (CFG and CFG.AWACS and CFG.AWACS.Label) or "MAGIC"
  local phrase = text or "This is a test of the text to speech system."
  local msg = string.format("%s. %s", label, phrase)
  env.info("TCS(CIC.AWACS): Testing TTS with phrase: " .. msg)
  _say(msg)
end

function TCS.CIC.AWACS.DispatchNATO(group, playerUnit, targetCoord, descriptor, tail)
  local CFG = GetCfg()
  if not group or not playerUnit or not playerUnit:IsAlive() or not targetCoord then return end
  local bull = TCS.NATO_BULLSEYE(targetCoord)
  local t = tail or "SURFACE"
  local phrase = string.format("%s. %s. %s. %s.", CFG.AWACS.Label, descriptor, bull, t)
  _say(phrase)
  if TCS.MsgToGroup then
    TCS.MsgToGroup(group, CFG.AWACS.Label .. ": " .. descriptor .. " | " .. bull .. " | " .. t, 12)
  end
end

-- The old Session-based update loops and legacy A2G overrides have been purged to align with the new Zone architecture.

env.info("TCS(CIC.AWACS): ready")