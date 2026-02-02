-- TCS_a2a.lua (A2A)
-- Reworked:
--   * ACM spawns are CLOSE-IN and SILENT (no controller/AWACS).
--   * INTERCEPT spawns are FARTHER and can spawn a RANDOM number of bandits (controller enabled).
--   * Controller logic applies to Intercept/CAP/Escort/BVR.
--   * Controller pacing prevents 'compressed' calls.

BanditGroupSet = SET_GROUP:New()
  :FilterPrefixes(CFG.Templates.BanditPrefix)
  :FilterCategoryAirplane()
  :FilterStart()

local function _getRandomBanditTemplateName()
  local g = BanditGroupSet:GetRandom()
  if not g then return nil end
  return g:GetName()
end

local function _anyAlive(groups)
  for _, g in ipairs(groups) do
    if g and g:IsAlive() then return true end
  end
  return false
end

local function _closestBanditAndRange(rec, banditGroups)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil, nil end
  local p = rec.Unit:GetCoordinate()
  local bestG, bestNM = nil, nil
  for _, g in ipairs(banditGroups) do
    if g and g:IsAlive() then
      local nm = CoordDistanceNM(p, g:GetCoordinate())
      if nm and ((not bestNM) or nm < bestNM) then bestNM, bestG = nm, g end
    end
  end
  return bestG, bestNM
end

local function AltFeetFromRef(refGroup, coord)
  local altm = nil
  if refGroup and refGroup.GetHeight then
    local ok, h = pcall(function() return refGroup:GetHeight() end)
    if ok and h then altm = h end
  end
  if (not altm) and refGroup and refGroup.GetAltitude then
    local ok, h = pcall(function() return refGroup:GetAltitude() end)
    if ok and h then altm = h end
  end
  if (not altm) and coord and coord.GetVec3 then
    local ok, v3 = pcall(function() return coord:GetVec3() end)
    if ok and v3 and v3.y then altm = v3.y end
  end
  return FeetFromMeters(altm or 0)
end

function A2A_BraaText(rec, refGroup)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return "" end
  if not refGroup or not refGroup:IsAlive() then return "" end
  local p = rec.Unit:GetCoordinate()
  local b = refGroup:GetCoordinate()

  local bearing = math.floor((p:HeadingTo(b) % 360) + 0.5)
  local rangeNM = CoordDistanceNM(p, b)
  if not rangeNM then return "" end
  rangeNM = math.floor(rangeNM + 0.5)

  local altFt = AltFeetFromRef(refGroup, b)
  altFt = math.floor((altFt / 1000) + 0.5) * 1000

  local banditHdg = 0
  pcall(function() banditHdg = refGroup:GetHeading() or 0 end)
  local b2p = math.floor((b:HeadingTo(p) % 360) + 0.5)
  local aspect = AspectHotFlankDrag(banditHdg, b2p)

  return string.format("BRAA %s/%d, %d THOUSAND, %s", Pad3(bearing), rangeNM, math.floor(altFt/1000), aspect)
end

local function _nearestAirbaseVec2(fromCoord)
  if not fromCoord then return nil end
  local ab = fromCoord:GetClosestAirbase()
  if not ab then return nil end
  return ab:GetVec2()
end

local function _tryRouteRTB(spawnGroup)
  if not CFG.A2A_CTRL.USE_RTB_ROUTE then return false end
  if not spawnGroup or not spawnGroup:IsAlive() then return false end
  local c = spawnGroup:GetCoordinate()
  local v2 = _nearestAirbaseVec2(c)
  if not v2 then return false end
  pcall(function() spawnGroup:TaskRouteToVec2(v2, 250, "Cone") end)
  return true
end

local function _trackSplashToGroup(playerGroup, spawnedGroup)
  local watcher = SET_GROUP:New()
  watcher:AddGroup(spawnedGroup)
  watcher:HandleEvent(EVENTS.UnitLost)
  function watcher:OnEventUnitLost(ed)
    if ed and ed.IniGroup == spawnedGroup then
      MsgToGroup(playerGroup, "SPLASH!! " .. tostring(ed.IniTypeName), 5)
    end
  end
end

local function SpawnBanditFromTemplate(templateName, alias, spawnCoord, spawnHeading, onSpawn)
  SPAWN:NewWithAlias(templateName, alias)
    :InitHeading(spawnHeading)
    :OnSpawnGroup(function(g)
      if onSpawn then onSpawn(g) end
    end)
    :SpawnFromVec3(spawnCoord)
end

-- ACM: silent close-in spawn. No controller/AWACS.
local function SpawnACMSingle(rec, spawnCoord, spawnHeading, label)
  local templateName = _getRandomBanditTemplateName()
  if not templateName then
    MsgToGroup(rec.Group, "No BANDIT templates available (need groups prefixed '" .. CFG.Templates.BanditPrefix .. "').", 10)
    return
  end

  SpawnBanditFromTemplate(templateName, "ACM_" .. math.random(1, 10000), spawnCoord, spawnHeading, function(spawnGroup)
    rec.ActiveBandits[spawnGroup:GetName()] = spawnGroup

    local fg = FLIGHTGROUP:New(spawnGroup):SetDetection(true)
    fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))

    _trackSplashToGroup(rec.Group, spawnGroup)

    MsgToGroup(rec.Group, "ACM (" .. label .. "): FIGHTS ON!", 10)
  end)
end

-- Shared controller manager (Intercept/BVR/CAP/Escort)
local function AutoManageBandits_Controller(rec, banditGroups, descriptor, isTerminatedFn, onTerminateFn, sessionName)
  local gates = CFG.A2A_CTRL
  local group = rec.Group
  local unit  = rec.Unit

  local function sayToAll(text, seconds)
    if sessionName then
      SESSION:Broadcast(sessionName, text, seconds)
    else
      MsgToGroup(group, text, seconds)
    end
  end

  local function ctrlCallAll(refGroup, descriptorText, brevityText, includeBraa)
    -- If in session and per-group BRAA enabled, send per member.
    if sessionName and CFG.SESSION and CFG.SESSION.BROADCAST_BRAA_TO_ALL then
      SESSION:ForEachMemberRec(sessionName, function(mrec)
        if not mrec or not mrec.Unit or not mrec.Unit:IsAlive() then return end
        local braa = ""
        if includeBraa and refGroup and refGroup:IsAlive() then
          braa = A2A_BraaText(mrec, refGroup)
        end
        AwacsControllerCallBraa(mrec.Group, mrec.Unit, refGroup and refGroup:GetCoordinate() or (mrec.Unit and mrec.Unit:GetCoordinate()), descriptorText, braa, brevityText)
      end)
      return
    end

    -- Solo / no session: just send to this group
    local braa = ""
    if includeBraa and refGroup and refGroup:IsAlive() then
      braa = A2A_BraaText(rec, refGroup)
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
      ctrlCallAll(ref, descriptor or "BANDITS", "TERMINATE", false)
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
    if not _anyAlive(banditGroups) then return end

    if (timer.getTime() - t0) > (gates.MAX_ENGAGE_SEC or 900) then
      terminate("TIMEOUT")
      return
    end

    local ref, dnm = _closestBanditAndRange(rec, banditGroups)
    if not ref or not dnm then return end

    local desc = hostile and "HOSTILE" or (descriptor or "BANDITS")

    if (not committed) and dnm <= (gates.COMMIT_GATE_NM or 60) and canTalk() then
      committed = true
      ctrlCallAll(ref, desc, "COMMIT", false)
      markTalk()
    end

    if committed and (not hostile) and dnm <= (gates.HOSTILE_GATE_NM or 45) and canTalk() then
      hostile = true
      ctrlCallAll(ref, "DECLARE", "HOSTILE", false)
      markTalk()

      SCHEDULER:New(nil, function()
        if not ref or not ref:IsAlive() or not unit or not unit:IsAlive() then return end
        local braa = A2A_BraaText(rec, ref)
        ctrlCallAll(ref, "HOSTILE", "CLEARED TO ENGAGE", true)
        markTalk()
      end, {}, gates.DECLARE_DELAY_SEC or 6, nil)
    end

    local function callAfterHostile(word)
      if not canTalk() then return end
      local braa = hostile and A2A_BraaText(rec, ref) or ""
      ctrlCallAll(ref, desc, word, hostile)
      markTalk()
    end

    if committed and (not pushed) and dnm <= (gates.PUSH_GATE_NM or 40) then pushed = true; callAfterHostile("PUSH") end
    if committed and (not pressed) and dnm <= (gates.PRESS_GATE_NM or 25) then pressed = true; callAfterHostile("PRESS") end
    if committed and (not merged) and dnm <= (gates.MERGE_GATE_NM or 15) then merged = true; callAfterHostile("MERGED") end
    if committed and merged and (not kio) and dnm <= (gates.KIO_GATE_NM or 10) then kio = true; callAfterHostile("KNOCK-IT-OFF ADVISORY") end

    if committed and dnm >= (gates.TERMINATE_GATE_NM or 120) then terminate("BANDITS OUT OF FIGHT"); return end
  end, {}, 5, 5)
end

-- Intercept: random number of bandits at increased distance, controller enabled.
local function SpawnIntercept(rec, baseHeadingDeg, minNM, maxNM, jitterDeg, count, spreadNM, outList)
  local playerCoord = rec.Unit:GetCoordinate()
  local centerRangeNM = minNM + math.random() * (maxNM - minNM)
  local jitter = math.random(-jitterDeg, jitterDeg)
  local center = playerCoord:Translate(centerRangeNM * 1852.0, baseHeadingDeg + jitter, true, false)

  -- 'count' is desired AIRCRAFT count (not groups). Templates may be 1-ship or 2-ship.
  local desiredAircraft = count or 1
  if desiredAircraft < 1 then desiredAircraft = 1 end

  local spawnedAircraft = 0
  local spawnedGroups = 0
  local safety = 0

  while spawnedAircraft < desiredAircraft and safety < 50 do
    safety = safety + 1
    local templateName = _getRandomBanditTemplateName()
    if not templateName then break end

    local templateSize = _templateUnitCount(templateName)
    spawnedGroups = spawnedGroups + 1

    local side = ((spawnedGroups % 2) == 0) and 90 or -90
    local offsetNM = (math.random() * (spreadNM or 4))
    local where = center:Translate(offsetNM * 1852.0, baseHeadingDeg + side, true, false)

    local alias = string.format("INT_%d_%d", spawnedGroups, math.random(1, 10000))
    local spawnHeading = (baseHeadingDeg + 180) % 360

    SpawnBanditFromTemplate(templateName, alias, where, spawnHeading, function(g)
      rec.ActiveBandits[g:GetName()] = g
      table.insert(outList, g)
      local fg = FLIGHTGROUP:New(g):SetDetection(true)
      fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))
      _trackSplashToGroup(rec.Group, g)
    end)

    spawnedAircraft = spawnedAircraft + templateSize
  end

  MsgToGroup(rec.Group, string.format("Spawned ~%d bandit aircraft (%d group(s)).", spawnedAircraft, spawnedGroups), 6)
end


-- Public entrypoints (ACM/Intercept/BVR) are left in this file for compatibility.
function StartABEAMDogFight(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "ABEAM")
  if cd then MsgToGroup(group, "ABEAM cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "ABEAM")

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()

  local spawnCoord = playerCoord:Translate(CFG.ACM.ABEAM_M, (hdg - 90), true, false)
  SpawnACMSingle(rec, spawnCoord, hdg, "ABeam")
end

function StartH2HDogFight(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "H2H")
  if cd then MsgToGroup(group, "H2H cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "H2H")

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()

  local spawnCoord = playerCoord:Translate(CFG.ACM.H2H_M, hdg, true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "H2H")
end

function StartDefensiveDogFight(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "DEFENSIVE")
  if cd then MsgToGroup(group, "DEFENSIVE cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "DEFENSIVE")

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()

  local spawnCoord = playerCoord:Translate(CFG.ACM.DEFENSIVE_M, (hdg - 180), true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "Defensive")
end

function StartIntercept(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "INTERCEPT")
  if cd then MsgToGroup(group, "INTERCEPT cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "INTERCEPT")

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local hdg = unit:GetHeading() or 0
  local count = math.random(CFG.INTERCEPT.MIN_BANDITS, CFG.INTERCEPT.MAX_BANDITS)

  local spawned = {}
  SpawnIntercept(rec, hdg, CFG.INTERCEPT.MIN_NM, CFG.INTERCEPT.MAX_NM, CFG.INTERCEPT.JITTER_DEG, count, CFG.INTERCEPT.SPREAD_NM, spawned)

  SCHEDULER:New(nil, function()
    if #spawned == 0 then MsgToGroup(rec.Group, "INTERCEPT: No bandits spawned (check templates).", 8); return end
    local ref, _ = _closestBanditAndRange(rec, spawned)
    if ref then
      AwacsControllerCallBraa(rec.Group, rec.Unit, ref:GetCoordinate(), "BANDITS GROUP", "", "STANDBY")
      if rec.Session then
        StartAwacsUpdatesSession(rec.Session, function()
          local r, _ = _closestBanditAndRange(rec, spawned)
          if r and r:IsAlive() then return r:GetCoordinate() end
          return nil
        end, "BANDITS GROUP", "track")
      else
        StartAwacsUpdates(rec.Group, rec.Unit, function()
          local r, _ = _closestBanditAndRange(rec, spawned)
          if r and r:IsAlive() then return r:GetCoordinate() end
          return nil
        end, "BANDITS GROUP", "track")
      end
    end

    AutoManageBandits_Controller(rec, spawned, "BANDITS GROUP", nil, nil, rec.Session)
    MsgToGroup(rec.Group, string.format("INTERCEPT: %d bandit(s) spawned.", #spawned), 8)
  end, {}, 6, nil)
end

function StartBVR(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "BVR")
  if cd then MsgToGroup(group, "BVR cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "BVR")

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0

  local jitter = math.random(-CFG.BVR.JITTER_DEG, CFG.BVR.JITTER_DEG)
  local spawnCoord = playerCoord:Translate(CFG.BVR.RANGE_M, (hdg + jitter), true, false)
  local spawnHeading = (hdg + 180) % 360

  local templateName = _getRandomBanditTemplateName()
  if not templateName then
    MsgToGroup(rec.Group, "No BANDIT templates available (need groups prefixed '" .. CFG.Templates.BanditPrefix .. "').", 10)
    return
  end

  SpawnBanditFromTemplate(templateName, "BVR_" .. math.random(1, 10000), spawnCoord, spawnHeading, function(spawnGroup)
    rec.ActiveBandits[spawnGroup:GetName()] = spawnGroup

    local fg = FLIGHTGROUP:New(spawnGroup):SetDetection(true)
    fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))
    _trackSplashToGroup(rec.Group, spawnGroup)

    AwacsControllerCallBraa(rec.Group, rec.Unit, spawnGroup:GetCoordinate(), "BANDIT", "", "INTERCEPT")
    if rec.Session then
      StartAwacsUpdatesSession(rec.Session, function()
        if spawnGroup and spawnGroup:IsAlive() then return spawnGroup:GetCoordinate() end
        return nil
      end, "BANDIT", "track")
    else
      StartAwacsUpdates(rec.Group, rec.Unit, function()
        if spawnGroup and spawnGroup:IsAlive() then return spawnGroup:GetCoordinate() end
        return nil
      end, "BANDIT", "track")
    end

    AutoManageBandits_Controller(rec, {spawnGroup}, "BANDIT", nil, nil, rec.Session)
    MsgToGroup(rec.Group, "BVR: Bandit spawned.", 8)
  end)
end

function StartBVRBracket(group)
  local rec = GetPlayer(group); if not rec then return end
  local cd, remain = OnCooldown(rec, "BVR_BRACKET")
  if cd then MsgToGroup(group, "BVR BRACKET cooldown: " .. remain .. "s", 5); return end
  MarkAction(rec, "BVR_BRACKET")

  local unit = rec.Unit
  if not unit or not unit:IsAlive() then return end

  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0

  local jitter = math.random(-CFG.BVR.JITTER_DEG, CFG.BVR.JITTER_DEG)
  local center = playerCoord:Translate(CFG.BVR.RANGE_M, (hdg + jitter), true, false)

  local left  = center:Translate(20000, (hdg - 90), true, false)
  local right = center:Translate(20000, (hdg + 90), true, false)

  local t1 = _getRandomBanditTemplateName()
  local t2 = _getRandomBanditTemplateName()
  if not t1 or not t2 then
    MsgToGroup(group, "No BANDIT templates available (need groups prefixed '" .. CFG.Templates.BanditPrefix .. "').", 10)
    return
  end

  local spawned = {}
  local function spawnOne(templateName, alias, where)
    SpawnBanditFromTemplate(templateName, alias, where, (hdg + 180) % 360, function(g)
      rec.ActiveBandits[g:GetName()] = g
      table.insert(spawned, g)
      local fg = FLIGHTGROUP:New(g):SetDetection(true)
      fg:AddMission(AUFTRAG:NewINTERCEPT(unit))
      _trackSplashToGroup(group, g)
    end)
  end

  spawnOne(t1, "BRKT_L_" .. math.random(1,10000), left)
  spawnOne(t2, "BRKT_R_" .. math.random(1,10000), right)

  SCHEDULER:New(nil, function()
    if #spawned == 0 then return end

    local ref, _ = _closestBanditAndRange(rec, spawned)
    if ref then
      AwacsControllerCallBraa(group, unit, ref:GetCoordinate(), "BANDITS GROUP", "", "STANDBY")
    end

    if rec.Session then
      StartAwacsUpdatesSession(rec.Session, function()
        local r, _ = _closestBanditAndRange(rec, spawned)
        if r and r:IsAlive() then return r:GetCoordinate() end
        return nil
      end, "BANDITS GROUP", "track")
    else
      StartAwacsUpdates(group, unit, function()
        local r, _ = _closestBanditAndRange(rec, spawned)
        if r and r:IsAlive() then return r:GetCoordinate() end
        return nil
      end, "BANDITS GROUP", "track")
    end

    AutoManageBandits_Controller(rec, spawned, "BANDITS GROUP", nil, nil, rec.Session)
    MsgToGroup(group, "BVR BRACKET: 2-ship spawned.", 8)
  end, {}, 6, nil)
end

function TerminateMyBandits(group)
  local rec = GetPlayer(group); if not rec then return end
  local count = 0
  for name, g in pairs(rec.ActiveBandits) do
    if g and g:IsAlive() then g:Destroy(); count = count + 1 end
    rec.ActiveBandits[name] = nil
  end
  MsgToGroup(group, "Terminated " .. tostring(count) .. " bandit group(s).", 8)
end

-- Expose controller manager + spawn helper for CAP/Escort modules
-- Template sizing + alive-aircraft counting (counts aircraft, not groups)
local _TemplateSizeCache = {}

local function _templateUnitCount(templateName)
  if _TemplateSizeCache[templateName] then return _TemplateSizeCache[templateName] end
  local n = 1
  local g = GROUP:FindByName(templateName)
  if g then
    if g.GetSize then
      n = g:GetSize()
    elseif g.GetUnits then
      local units = g:GetUnits()
      if units then n = #units end
    end
  end
  if not n or n < 1 then n = 1 end
  _TemplateSizeCache[templateName] = n
  return n
end

local function _aliveAircraftCount(groups)
  local n = 0
  for _, g in ipairs(groups or {}) do
    if g and g.IsAlive and g:IsAlive() then
      if g.CountAliveUnits then
        n = n + g:CountAliveUnits()
      elseif g.GetUnits then
        local units = g:GetUnits() or {}
        n = n + #units
      else
        n = n + 1
      end
    end
  end
  return n
end


A2A = {
  SpawnBanditFromTemplate = SpawnBanditFromTemplate,
  GetRandomBanditTemplateName = _getRandomBanditTemplateName,
  AutoManageBandits_Controller = AutoManageBandits_Controller,
  ClosestBanditAndRange = _closestBanditAndRange,
  AnyAlive = _anyAlive,
  BraaText = A2A_BraaText,
  TemplateUnitCount = _templateUnitCount,
  AliveAircraftCount = _aliveAircraftCount,
}

