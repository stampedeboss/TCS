---------------------------------------------------------------------
-- RANGE + STRAFE integration for DCSServerBot
-- Stateless, UCID-based, MOOSE-native
---------------------------------------------------------------------

env.info("[RANGE_EVENTS] Loaded")

local RangeEvents = {}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

local function ResolveUCID(unit)
  if not unit then return nil end
  if PILOT_ID and PILOT_ID.FromUnit then
    local id = PILOT_ID.FromUnit(unit)
    if id and id.ucid then
      return id
    end
  end
  return nil
end

local function SendEvent(msg)
  if not dcsbot or not dcsbot.sendBotTable then
    env.warn("[RANGE_EVENTS] DCSServerBot not available")
    return
  end
  dcsbot.sendBotTable(msg)
end

local function SafeCall(label, fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then
    env.error(string.format("[RANGE_EVENTS][%s] %s", label, tostring(err)))
  end
end

---------------------------------------------------------------------
-- Bombing callback
---------------------------------------------------------------------

function RangeEvents.AttachBombing(range)
  function range:OnAfterImpact(From, Event, To, impact)
    SafeCall("BombImpact", function()
      if not impact or not impact.unit then return end

      local id = ResolveUCID(impact.unit)
      if not id then return end

      local msg = {
        command   = "onMissionEvent",
        eventName = "S_EVENT_RANGE_BOMB",
        initiator = {
          ucid = id.ucid,
          name = id.name,
          unit = impact.unit:GetName()
        },
        range = {
          name     = self.RangeName,
          zone     = impact.zone,
          weapon   = impact.weapon,
          distance = impact.distance, -- meters
          score    = impact.score
        },
        time = timer.getTime()
      }

      SendEvent(msg)
    end)
  end
end

---------------------------------------------------------------------
-- Strafe callback
---------------------------------------------------------------------

function RangeEvents.AttachStrafe(range)
  function range:OnAfterStrafeResult(From, Event, To, result)
    SafeCall("StrafeResult", function()
      if not result or not result.unit then return end

      local id = ResolveUCID(result.unit)
      if not id then return end

      local msg = {
        command   = "onMissionEvent",
        eventName = "S_EVENT_RANGE_STRAFE",
        initiator = {
          ucid = id.ucid,
          name = id.name,
          unit = result.unit:GetName()
        },
        range = {
          name     = self.RangeName,
          pit      = result.pit,
          rounds   = result.rounds,
          hits     = result.hits,
          accuracy = result.accuracy,
          score    = result.score
        },
        time = timer.getTime()
      }

      SendEvent(msg)
    end)
  end
end

---------------------------------------------------------------------
-- Convenience: Attach both
---------------------------------------------------------------------

function RangeEvents.AttachAll(range)
  RangeEvents.AttachBombing(range)
  RangeEvents.AttachStrafe(range)
end

---------------------------------------------------------------------

local R = RANGE:New("TCS Range")

local targets = SET_STATIC:New()
  :FilterPrefixes("Static ISO container-")
  :FilterOnce()

targets:ForEachStatic(function(s)
  local name = s:GetName()

  -- Extract the trailing number
  local idx = tonumber(name:match("-(%d+)$"))

  if not idx then
    env.warn("[RANGE] Could not parse index from " .. name)
    return
  end

  if idx == 1 or idx == 2 then
    -- Bombing targets
    env.info("[RANGE] Adding BOMB target: " .. name)
    R:AddBombingTargets({ name })
  else
    -- Strafe targets
    env.info("[RANGE] Adding STRAFE pit: " .. name)
    R:AddStrafePit(name, 3000, 300)
  end
end)

R:SetF10Menu(true)
R:SetAutosave(true)
