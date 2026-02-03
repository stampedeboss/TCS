-- tcs_a2a_intercept.lua
-- Spawns bandits at range for interception.

local CFG = TCS.A2A.Config
local A2A = TCS.A2A

TCS.A2A.Intercept = {}

local function SpawnIntercept(session, rec, baseHeadingDeg, minNM, maxNM, jitterDeg, count, spreadNM, outList)
  local playerCoord = rec.Unit:GetCoordinate()
  local centerRangeNM = minNM + math.random() * (maxNM - minNM)
  local jitter = math.random(-jitterDeg, jitterDeg)
  local center = playerCoord:Translate(centerRangeNM * 1852.0, baseHeadingDeg + jitter, true, false)

  local desiredAircraft = count or 1
  if desiredAircraft < 1 then desiredAircraft = 1 end

  local spawnedAircraft = 0
  local spawnedGroups = 0
  local safety = 0

  while spawnedAircraft < desiredAircraft and safety < 50 do
    safety = safety + 1
    local banditDef = A2A.GetBanditDef() -- Default random
    if not banditDef then break end

    local templateSize = 1 -- Dynamic spawns are 1-ship for now unless configured
    spawnedGroups = spawnedGroups + 1

    local side = ((spawnedGroups % 2) == 0) and 90 or -90
    local offsetNM = (math.random() * (spreadNM or 4))
    local where = center:Translate(offsetNM * 1852.0, baseHeadingDeg + side, true, false)

    local alias = string.format("INT_%d_%d", spawnedGroups, math.random(1, 10000))
    local spawnHeading = (baseHeadingDeg + 180) % 360

    A2A.SpawnBandit(session, banditDef, alias, where, spawnHeading, function(g)
      table.insert(outList, g)
      local fg = FLIGHTGROUP:New(g):SetDetection(true)
      fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))
      A2A.TrackSplash(rec.Group, g)
    end)

    spawnedAircraft = spawnedAircraft + templateSize
  end

  MsgToGroup(rec.Group, string.format("Spawned ~%d bandit aircraft (%d group(s)).", spawnedAircraft, spawnedGroups), 6)
end

function TCS.A2A.Intercept.Start(group)
  local rec = PLAYERS:GetByGroup(group); if not rec then return end
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  local cd, remain = PLAYERS:OnCooldown(rec, "INTERCEPT")
  if cd then MsgToGroup(group, "INTERCEPT cooldown: " .. remain .. "s", 5); return end
  PLAYERS:MarkAction(rec, "INTERCEPT", (CFG.Cooldowns and CFG.Cooldowns.INTERCEPT) or 90)

  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local hdg = unit:GetHeading() or 0
  local count = math.random(CFG.INTERCEPT.MIN_BANDITS, CFG.INTERCEPT.MAX_BANDITS)

  local spawned = {}
  SpawnIntercept(session, rec, hdg, CFG.INTERCEPT.MIN_NM, CFG.INTERCEPT.MAX_NM, CFG.INTERCEPT.JITTER_DEG, count, CFG.INTERCEPT.SPREAD_NM, spawned)

  SCHEDULER:New(nil, function()
    if #spawned == 0 then MsgToGroup(rec.Group, "INTERCEPT: No bandits spawned.", 8); return end
    local ref, _ = A2A.ClosestBanditAndRange(rec, spawned)
    if ref then AwacsControllerCallBraa(rec.Group, rec.Unit, ref:GetCoordinate(), "BANDITS GROUP", "", "STANDBY") end
    TCS.A2A.Controller.AutoManage(rec, spawned, "BANDITS GROUP", nil, nil, session:GetName())
    MsgToGroup(rec.Group, string.format("INTERCEPT: %d bandit(s) spawned.", #spawned), 8)
  end, {}, 6, nil)
end

-- Alias for backward compatibility with Training/Menu
TCS.A2A.StartIntercept = TCS.A2A.Intercept.Start