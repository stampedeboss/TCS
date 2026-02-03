-- tcs_a2a_controller.lua
-- Manages the state and communication for an A2A engagement.

local CFG = TCS.A2A.Config
local Sessions = TCS.Sessions
local A2A = TCS.A2A

TCS.A2A.Controller = {}

local function _tryRouteRTB(spawnGroup)
  if not CFG.A2A_CTRL.USE_RTB_ROUTE then return false end
  if not spawnGroup or not spawnGroup:IsAlive() then return false end
  local c = spawnGroup:GetCoordinate()
  local v2 = GetNearestAirbaseVec2(c)
  if not v2 then return false end
  pcall(function() spawnGroup:TaskRouteToVec2(v2, 250, "Cone") end)
  return true
end

function TCS.A2A.Controller.AutoManage(rec, banditGroups, descriptor, isTerminatedFn, onTerminateFn, sessionName)
  local gates = CFG.A2A_CTRL
  local group = rec.Group
  local unit  = rec.Unit

  local function sayToAll(text, seconds)
    if sessionName then
      Sessions:Broadcast(sessionName, text, seconds)
    else
      MsgToGroup(group, text, seconds)
    end
  end

  local function ctrlCallAll(refGroup, descriptorText, brevityText, includeBraa)
    if sessionName and CFG.SESSION and CFG.SESSION.BROADCAST_BRAA_TO_ALL and Sessions then
      Sessions:ForEachMemberRec(sessionName, function(mrec)
        if not mrec or not mrec.Unit or not mrec.Unit:IsAlive() then return end
        local braa = ""
        if includeBraa and refGroup and refGroup:IsAlive() then
          braa = A2A.BraaText(mrec, refGroup)
        end
        AwacsControllerCallBraa(mrec.Group, mrec.Unit, refGroup and refGroup:GetCoordinate() or (mrec.Unit and mrec.Unit:GetCoordinate()), descriptorText, braa, brevityText)
      end)
      return
    end

    local braa = ""
    if includeBraa and refGroup and refGroup:IsAlive() then
      braa = A2A.BraaText(rec, refGroup)
    end
    AwacsControllerCallBraa(group, unit, refGroup and refGroup:GetCoordinate() or (unit and unit:GetCoordinate()), descriptorText, braa, brevityText)
  end

  if not group or not unit then return end

  local t0 = timer.getTime()
  local committed, hostile = false, false
  local pushed, pressed, merged, kio = false, false, false, false
  local terminated = false
  local lastCtrlTime = 0

  local function canTalk()
    return (timer.getTime() - lastCtrlTime) >= (gates.MIN_CTRL_SPACING_SEC or 10)
  end
  local function markTalk() lastCtrlTime = timer.getTime() end

  local function terminate(reason)
    if terminated then return end
    terminated = true

    if onTerminateFn then pcall(function() onTerminateFn(reason) end) end

    if canTalk() then
      ctrlCallAll(nil, descriptor or "BANDITS", "TERMINATE", false)
      markTalk()
    end

    for _, g in ipairs(banditGroups) do
      if g and g:IsAlive() then _tryRouteRTB(g) end
    end

    SCHEDULER:New(nil, function()
      for _, g in ipairs(banditGroups) do
        if g and g:IsAlive() then g:Destroy() end
      end
    end, {}, gates.RTB_GRACE_SEC or 180, nil)
  end

  SCHEDULER:New(nil, function()
    if terminated then return end
    if isTerminatedFn and isTerminatedFn() then terminate("MODE ENDED"); return end

    if not unit or not unit:IsAlive() then
      terminate("PLAYER DOWN")
      return
    end
    if not A2A.AnyAlive(banditGroups) then return end

    if (timer.getTime() - t0) > (gates.MAX_ENGAGE_SEC or 900) then
      terminate("TIMEOUT")
      return
    end

    local ref, dnm = A2A.ClosestBanditAndRange(rec, banditGroups)
    if not ref or not dnm then return end

    local desc = hostile and "HOSTILE" or (descriptor or "BANDITS")

    if (not committed) and dnm <= (gates.COMMIT_GATE_NM or 60) and canTalk() then committed = true; ctrlCallAll(ref, desc, "COMMIT", false); markTalk() end
    if committed and (not hostile) and dnm <= (gates.HOSTILE_GATE_NM or 45) and canTalk() then hostile = true; ctrlCallAll(ref, "DECLARE", "HOSTILE", false); markTalk(); SCHEDULER:New(nil, function() if not ref or not ref:IsAlive() or not unit or not unit:IsAlive() then return end; ctrlCallAll(ref, "HOSTILE", "CLEARED TO ENGAGE", true); markTalk() end, {}, gates.DECLARE_DELAY_SEC or 6, nil) end

    local function callAfterHostile(word) if not canTalk() then return end; local braa = hostile and A2A.BraaText(rec, ref) or ""; ctrlCallAll(ref, desc, word, hostile); markTalk() end

    if committed and (not pushed) and dnm <= (gates.PUSH_GATE_NM or 40) then pushed = true; callAfterHostile("PUSH") end
    if committed and (not pressed) and dnm <= (gates.PRESS_GATE_NM or 25) then pressed = true; callAfterHostile("PRESS") end
    if committed and (not merged) and dnm <= (gates.MERGE_GATE_NM or 15) then merged = true; callAfterHostile("MERGED") end
    if committed and merged and (not kio) and dnm <= (gates.KIO_GATE_NM or 10) then kio = true; callAfterHostile("KNOCK-IT-OFF ADVISORY") end

    if committed and dnm >= (gates.TERMINATE_GATE_NM or 120) then terminate("BANDITS OUT OF FIGHT"); return end
  end, {}, 5, 5)
end

-- Alias for backward compatibility with CAP/Escort/Sweep modules
TCS.A2A.AutoManageBandits_Controller = TCS.A2A.Controller.AutoManage