---------------------------------------------------------------------
-- A2G TCS Range Module (MP-safe, owner-aware)
-- Group-based (1 aircraft per group)
-- Shared scoring, exclusive control
---------------------------------------------------------------------

A2G_RANGE = {
  Ranges = {}   -- keyed by group name
}

---------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------

local NM_TO_M  = 1852
local START_NM = 30
local STEP_NM  = 5
local MAX_NM   = 60

---------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------

local function ResolveUCID(unit)
  if not unit then return nil end
  -- Try PILOT_ID if available (FunkMan/Core integration)
  if PILOT_ID and PILOT_ID.FromUnit then
    local id = PILOT_ID.FromUnit(unit)
    if id and id.ucid then return id end
  end
  -- Fallback
  return {
    ucid = nil,
    name = unit:GetPlayerName() or "AI"
  }
end

local function SendBotEvent(msg)
  if dcsbot and dcsbot.sendBotTable then
    dcsbot.sendBotTable(msg)
  end
end

local function DestroyStatics(range)
  for _, obj in ipairs(range.statics) do
    if obj and obj:isExist() then
      obj:destroy()
    end
  end
  range.statics = {}
end

local function DestroyMobiles(range)
  for _, grp in ipairs(range.mobiles or {}) do
    if grp and grp:isExist() then
      grp:destroy()
    end
  end
  range.mobiles = {}
end

local function SpawnStatic(range, data)
  local obj = coalition.addStaticObject(range.enemyCoalition or coalition.side.RED, data)
  table.insert(range.statics, obj)
end

local function SpawnMobile(range, data)
  local group = coalition.addGroup(range.enemyCoalition or coalition.side.RED, Group.Category.GROUND, data)
  if group then
    table.insert(range.mobiles, group)
  end
end

---------------------------------------------------------------------
-- Terrain & Density Checks
---------------------------------------------------------------------

local function IsUsableTerrain(coord)
  if land.getSurfaceType({ x = coord.x, y = coord.z }) == land.SurfaceType.WATER then
    return false
  end

  local h1 = coord:GetLandHeight()
  local h2 = coord:Translate(10, 0):GetLandHeight()
  if math.abs(h1 - h2) > 2.0 then
    return false
  end

  -- Reject dense city cores only
  local count = 0
  world.searchObjects(
    Object.Category.SCENERY,
    {
      id = world.VolumeType.SPHERE,
      params = {
        point  = { x = coord.x, y = h1, z = coord.z },
        radius = 300
      }
    },
    function()
      count = count + 1
      return count < 30
    end
  )

  return count < 25
end

---------------------------------------------------------------------
-- Anchor Finder (forward-only)
---------------------------------------------------------------------

local function FindAnchorAhead(unit)
  local coord = unit:GetCoordinate()
  local track = unit:GetHeading()
  local offsets = { 0, 15, -15, 30, -30 }

  for dist = START_NM, MAX_NM, STEP_NM do
    for _, offset in ipairs(offsets) do
      local scanHdg = track + offset
      local test = coord:Translate(dist * NM_TO_M, scanHdg)
      if IsUsableTerrain(test) then
        return test, dist
      end
    end
  end

  return nil, nil
end

---------------------------------------------------------------------
-- Range Lifecycle
---------------------------------------------------------------------

local function DestroyRange(groupName)
  local range = A2G_RANGE.Ranges[groupName]
  if not range then return end

  if range.moose then
    range.moose:Stop()
  end

  DestroyStatics(range)
  DestroyMobiles(range)
  A2G_RANGE.Ranges[groupName] = nil

  env.info("[A2G_RANGE] Destroyed range owned by " .. groupName)
end

---------------------------------------------------------------------
-- MOOSE RANGE Setup (per range)
---------------------------------------------------------------------

local function CreateMooseRange(range, groupName)
  local r = RANGE:New("A2G_RANGE_" .. groupName)

  r:SetScoreBombing(true)
  r:SetScoreStrafing(true)
  r:SetBombingAccuracy(true)
  r:SetStrafeAccuracy(true)

  function r:OnAfterBombingResult(EventData)
    local unit = EventData.IniUnit
    local id = ResolveUCID(unit)
    
    -- Send to DCSServerBot
    local msg = {
      command   = "onMissionEvent",
      eventName = "S_EVENT_RANGE_BOMB",
      initiator = {
        ucid = id.ucid,
        name = id.name,
        unit = unit and unit:GetName() or "UNKNOWN"
      },
      range = {
        name     = "A2G_RANGE_" .. groupName,
        weapon   = EventData.WeaponName or "UNKNOWN",
        distance = EventData.Distance or -1, -- meters
        score    = EventData.Score or 0
      },
      time = timer.getTime()
    }
    SendBotEvent(msg)
  end

  function r:OnAfterStrafeResult(EventData)
    local unit = EventData.IniUnit
    local id = ResolveUCID(unit)

    -- Send to DCSServerBot
    local msg = {
      command   = "onMissionEvent",
      eventName = "S_EVENT_RANGE_STRAFE",
      initiator = {
        ucid = id.ucid,
        name = id.name,
        unit = unit and unit:GetName() or "UNKNOWN"
      },
      range = {
        name     = "A2G_RANGE_" .. groupName,
        rounds   = EventData.RoundsFired or 0,
        hits     = EventData.RoundsHit or 0,
        score    = EventData.Score or 0
      },
      time = timer.getTime()
    }
    SendBotEvent(msg)
  end

  range.moose = r
  r:Start()
end

---------------------------------------------------------------------
-- Layouts
---------------------------------------------------------------------

local Layouts = {}

Layouts.ISO = function(range, center, track)
  for i = 1, 10 do
    local c = center:Translate((i - 1) * 10, track + 90)
    SpawnStatic(range, {
      category   = "Cargo",
      type       = "Container",
      shape_name = "container_cargo",
      name       = range.id .. "_ISO_" .. i,
      x          = c.x,
      y          = c.z,
      heading    = track
    })
  end
end

Layouts.BOMB = function(range, center)
  for i = 1, 8 do
    local a = (360 / 8) * i
    local c = center:Translate(50, a)
    SpawnStatic(range, {
      category   = "Cargo",
      type       = "Container",
      shape_name = "container_cargo",
      name       = range.id .. "_BOMB_" .. i,
      x          = c.x,
      y          = c.z,
      heading    = a
    })
  end
end

Layouts.STRAFE = function(range, center, track)
  for i = 1, 6 do
    local c = center:Translate(i * 25, track)
    SpawnStatic(range, {
      category = "Unarmed",
      type     = "Hummer",
      name     = range.id .. "_STR_" .. i,
      x        = c.x,
      y        = c.z,
      heading  = track
    })
  end
end

Layouts.MIXED = function(range, center, track)
  Layouts.ISO(range, center, track)
  Layouts.STRAFE(range, center:Translate(200, track + 90), track)
end

local function CreateMovingGroup(range, center, track, unitType, suffix)
  -- 3km crossing path perpendicular to range axis
  local startPt = center:Translate(1500, track - 90)
  local endPt   = center:Translate(1500, track + 90)

  local units = {}
  for i = 1, 5 do
    -- Column formation trailing the start point
    local uPos = startPt:Translate((i-1)*50, track - 90)
    table.insert(units, {
      name = range.id .. "_" .. suffix .. "_" .. i,
      type = unitType,
      x = uPos.x,
      y = uPos.z,
      heading = (track + 90) * (math.pi/180),
      skill = "High"
    })
  end

  local route = {
    points = {
      [1] = {
        x = startPt.x,
        y = startPt.z,
        action = "Off Road",
        speed = 11, -- ~40 kph
        type = "Turning Point",
      },
      [2] = {
        x = endPt.x,
        y = endPt.z,
        action = "Off Road",
        speed = 11,
        type = "Turning Point",
      }
    }
  }

  SpawnMobile(range, {
    name = range.id .. "_" .. suffix .. "_GRP",
    task = "Ground Nothing",
    route = route,
    units = units
  })
end

Layouts.MOVING = function(range, center, track)
  CreateMovingGroup(range, center, track, "Ural-375", "MOV")
end

Layouts.MOVING_HOSTILE = function(range, center, track)
  CreateMovingGroup(range, center, track, "BMP-2", "MOV_H")
end

Layouts.POPUP = function(range, center, track)
  local units = {}
  -- SA-13 Strela-10M3
  table.insert(units, {
    name = range.id .. "_SAM",
    type = "Strela-10M3",
    x = center.x,
    y = center.z,
    heading = track * (math.pi/180),
    skill = "High"
  })

  SpawnMobile(range, {
    name = range.id .. "_SAM_GRP",
    task = "Ground Nothing",
    units = units
  })

  -- Add some ISO containers as targets
  Layouts.ISO(range, center:Translate(400, track), track)
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function A2G_RANGE.Build(groupName, unitName, layout)
  local group = GROUP:FindByName(groupName)
  local unit  = UNIT:FindByName(unitName)
  if not group or not unit then return end

  -- Ownership check
  if A2G_RANGE.Ranges[groupName] then
    MESSAGE:New("You already own a range.", 8):ToGroup(group)
    return
  end

  local anchor, dist = FindAnchorAhead(unit)
  if not anchor then
    MESSAGE:New("No suitable range location found.", 8):ToGroup(group)
    return
  end

  local pCoal = group:GetCoalition()
  local eCoal = (pCoal == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE

  local range = {
    id      = groupName,
    owner   = groupName,
    statics = {},
    mobiles = {},
    moose   = nil,
    enemyCoalition = eCoal
  }

  A2G_RANGE.Ranges[groupName] = range
  CreateMooseRange(range, groupName)

  Layouts[layout](range, anchor, unit:GetHeading())

  MESSAGE:New(
    string.format("RANGE BUILT %d NM AHEAD (%s)", dist, layout),
    10
  ):ToAll()
end

function A2G_RANGE.Reset(groupName)
  DestroyRange(groupName)
end

---------------------------------------------------------------------
-- Owner death / despawn cleanup
---------------------------------------------------------------------

A2G_RANGE.Handler = EVENTHANDLER:New()

A2G_RANGE.Handler:HandleEvent(EVENTS.Dead)
A2G_RANGE.Handler:HandleEvent(EVENTS.Crash)
A2G_RANGE.Handler:HandleEvent(EVENTS.Ejection)
A2G_RANGE.Handler:HandleEvent(EVENTS.PlayerLeaveUnit)

function A2G_RANGE.Handler:OnEvent(event)
  if not event.IniGroup then return end
  local groupName = event.IniGroup:GetName()

  if A2G_RANGE.Ranges[groupName] then
    DestroyRange(groupName)
  end
end

-- Namespace Alias
TCS = TCS or {}; TCS.A2G = TCS.A2G or {}
TCS.A2G.Range = A2G_RANGE
