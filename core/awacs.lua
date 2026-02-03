-- TCS_awacs.lua (A2A)
AWACS = nil

-- Ensure we reference the correct config
local function GetCfg() return TCS.A2A.Config end

function SetupAwacs()
  local CFG = GetCfg()
  local bull = ResolveBullseye()
  if not bull then
    MESSAGE:New("WARNING: No trigger zone named 'BULLSEYE'. Bullseye calls disabled until you add it.", 15)
      :ToCoalition(CFG.Coalition)
  end

  if MSRS then
    AWACS = MSRS:New(CFG.AWACS.SRSPath, CFG.AWACS.Freq, CFG.AWACS.Mod)
    AWACS:SetCoalition(CFG.Coalition)
    AWACS:SetLabel(CFG.AWACS.Label)
    AWACS:SetCulture("en-US")
    AWACS:SetGender("male")
    AWACS:SetVolume(1.0)
  else
    MESSAGE:New("WARNING: MSRS not found. SRS TTS disabled (text backup still works).", 15)
      :ToCoalition(CFG.Coalition)
  end
end

local function _say(text) if AWACS and text then AWACS:PlayText(text, 0) end end

function AwacsDispatchNATO(group, playerUnit, targetCoord, descriptor, tail)
  local CFG = GetCfg()
  if not group or not playerUnit or not playerUnit:IsAlive() or not targetCoord then return end
  local bull = NATO_BULLSEYE(targetCoord)
  local t = tail or "SURFACE"
  local phrase = string.format("%s. %s. %s. %s.", CFG.AWACS.Label, descriptor, bull, t)
  _say(phrase)
  MsgToGroup(group, CFG.AWACS.Label .. ": " .. descriptor .. " | " .. bull .. " | " .. t, 12)
end

function AwacsControllerCallBraa(group, playerUnit, refCoord, descriptor, braaText, brevity)
  local CFG = GetCfg()
  if not group or not playerUnit or not playerUnit:IsAlive() or not refCoord then return end
  local bull = NATO_BULLSEYE(refCoord)
  local d = descriptor or "BANDIT"
  local b = (braaText and braaText ~= "") and (" " .. braaText .. ".") or ""
  local tail = brevity or "SURFACE"
  local phrase = string.format("%s. %s.%s %s. %s.", CFG.AWACS.Label, d, b, bull, tail)
  _say(phrase)
  MsgToGroup(group, CFG.AWACS.Label .. ": " .. d .. " | " .. (braaText or "") .. " | " .. bull .. " | " .. tail, 12)
end

function StartAwacsUpdates(group, playerUnit, getTargetCoordFn, descriptor, tailMode)
  local CFG = GetCfg()
  if not group or not playerUnit or not getTargetCoordFn then return end
  local endTime = timer.getTime() + (CFG.AWACS.UpdateTotal or 180)
  local interval = (CFG.AWACS.UpdateEvery or 30)
  local lastCoord = nil

  SCHEDULER:New(nil, function()
    if timer.getTime() > endTime then return end
    if not playerUnit or not playerUnit:IsAlive() then return end
    local tc = getTargetCoordFn()
    if not tc then return end

    local tail = "SURFACE"
    if tailMode == "track" then tail = NATO_TRACK(lastCoord, tc) or "SURFACE" end
    AwacsDispatchNATO(group, playerUnit, tc, "UPDATE " .. descriptor, tail)
    lastCoord = tc
  end, {}, interval, interval)
end


function StartAwacsUpdatesSession(sessionName, getTargetCoordFn, descriptor, tailMode)
  if not sessionName or not SESSION then return end
  SESSION:ForEachMemberRec(sessionName, function(rec)
    if rec and rec.Group and rec.Unit then
      StartAwacsUpdates(rec.Group, rec.Unit, getTargetCoordFn, descriptor, tailMode)
    end
  end)
end

---------------------------------------------------------------------
-- A2G AWACS Interface
---------------------------------------------------------------------
TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.AWACS = {}

function TCS.A2G.AWACS:AssignBAI(group, anchor, echelon)
  local unit = group:GetUnit(1)
  if unit and anchor then
     AwacsDispatchNATO(group, unit, anchor, "BAI TASKING", "ENGAGE")
  end
end
