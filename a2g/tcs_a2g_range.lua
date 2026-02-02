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

local function DestroyStatics(range)
  for _, obj in ipairs(range.statics) do
    if obj and obj:isExist() then
      obj:destroy()
    end
  end
  range.statics = {}
end

local function SpawnStatic(range, data)
  local obj = coalition.addStaticObject(coalition.side.BLUE, data)
  table.insert(range.statics, obj)
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

  for dist = START_NM, MAX_NM, STEP_NM do
    local test = coord:Translate(dist * NM_TO_M, track)
    if IsUsableTerrain(test) then
      return test, dist
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
    A2G_RANGE.Export(groupName, {
      pass     = "BOMB",
      pilot    = EventData.IniPlayerName or "UNKNOWN",
      aircraft = EventData.IniTypeName or "UNKNOWN",
      weapon   = EventData.Weapon or "UNKNOWN",
      distance = EventData.Distance or -1,
    })
  end

  function r:OnAfterStrafeResult(EventData)
    A2G_RANGE.Export(groupName, {
      pass     = "STRAFE",
      pilot    = EventData.IniPlayerName or "UNKNOWN",
      aircraft = EventData.IniTypeName or "UNKNOWN",
      rounds   = EventData.RoundCount or 0,
      hits     = EventData.Hits or 0,
      score    = EventData.Score or 0,
    })
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

  local range = {
    id      = groupName,
    owner   = groupName,
    statics = {},
    moose   = nil
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

---------------------------------------------------------------------
-- Export (DCSServerBot / FunkMan)
---------------------------------------------------------------------

function A2G_RANGE.Export(ownerGroup, data)
  data.owner     = ownerGroup
  data.timestamp = timer.getAbsTime()

  env.info("[A2G_RANGE] " .. mist.utils.serialize("", data))
end
