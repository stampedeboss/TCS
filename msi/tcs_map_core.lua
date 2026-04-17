---------------------------------------------------------------------
-- DCS.MIS (DCS Map Initialization System) CORE
-- Common utilities for theater initialization and management.
---------------------------------------------------------------------
env.info("DCS.MIS(CORE): loading")

_G.DCS = _G.DCS or {}
_G.DCS.MIS = _G.DCS.MIS or {}
DCS.MIS.Active = nil -- Will hold the active map config table

-- Helper: Sanitize warehouses at neutral bases
function DCS.MIS.SanitizeNeutrals(baseNames)
  if not baseNames then return end
  for _, name in ipairs(baseNames) do
    local ab = Airbase.getByName(name)
    if ab then
      local wh = ab:getWarehouse()
      if wh then
        wh:clear()
        env.info("DCS.MIS: Sanitized warehouse (Weapons/Fuel removed) at Neutral base: " .. name)
      end
    else
      env.warning("DCS.MIS: Could not find airbase for sanitization: " .. name)
    end
  end
end

--- Spawns a group from a raw data template.
-- @param name (string) The name for the new group.
-- @param template (table) A table containing `category`, `units`, and optional `route`.
-- @param pos (table) A table with {x, y} map coordinates for the spawn point.
-- @param heading (number) The initial heading in degrees.
-- @param side (number|nil) Coalition side (default: RED).
function DCS.MIS.SpawnGroup(name, template, pos, heading, side)
  local groupData = {
    name = name,
    task = template.category == Group.Category.AIRPLANE and "CAP" or "Ground Nothing",
    units = {}
  }

  for i, unitType in ipairs(template.units) do
    local offset = (i - 1) * 20
    table.insert(groupData.units, {
      name = name .. "_U" .. i,
      type = unitType,
      x = pos.x + offset,
      y = pos.y + offset,
      heading = math.rad(heading),
      skill = "High"
    })
  end

  if template.route then
    groupData.route = template.route
  else
    -- Default route to prevent idle state
    groupData.route = {
      points = {
        [1] = {
          x = pos.x,
          y = pos.y,
          action = "Off Road",
          type = "Turning Point",
          speed = 0
        }
      }
    }
  end

  coalition.addGroup(side or coalition.side.RED, template.category, groupData)
end

-- Helper: Register the active map
function DCS.MIS.Register(mapConfig)
  if env.mission.theatre == mapConfig.Name then
    DCS.MIS.Active = mapConfig
    env.info("DCS.MIS: Active Theater Registered: " .. mapConfig.Name)
    if mapConfig.Init then
      mapConfig.Init()
    end
  end
end

--- Builds a standing range (MIS Wrapper for TCS).
-- @param name (string) Unique identifier for the range.
-- @param vec3 (table) Center point {x, y, z}.
-- @param heading (number) Orientation heading in degrees.
-- @param configKey (string) Name of the range configuration.
function DCS.MIS.BuildStandingRange(name, vec3, heading, configKey)
  if TCS.RANGE and TCS.RANGE.Spawn then
    TCS.RANGE.Spawn(name, "SYSTEM", vec3, heading, configKey)
    env.info("DCS.MIS: Built standing range '" .. name .. "'")
  end
end

---------------------------------------------------------------------
-- MIS Strike Manager (Persistent Targets)
---------------------------------------------------------------------
DCS.MIS.StrikeManager = {}
local Manager = DCS.MIS.StrikeManager
Manager.Targets = {} -- Registry of managed targets

-- Defaults
local DEFAULT_REGEN_TIME = 3600 -- 1 hour

--- Adds a persistent strike target to the manager.
-- @param id (string) Unique identifier for this target instance.
-- @param template (table) Lua template table {category, units}.
-- @param coord (Coordinate) MOOSE Coordinate object for the spawn location.
-- @param heading (number) Heading in degrees.
-- @param regenTime (number) Time in seconds to regenerate after destruction.
function Manager.AddTarget(id, template, coord, heading, regenTime)
  if Manager.Targets[id] then
    env.warning("DCS.MIS.StrikeManager: Target " .. tostring(id) .. " already exists. Skipping.")
    return
  end

  local target = {
    ID = id,
    Template = template,
    Coord = coord,
    Heading = heading or 0,
    RegenTime = regenTime or DEFAULT_REGEN_TIME,
    Group = nil,
    DeadTime = nil,
    State = "PENDING" -- PENDING, ALIVE, DEAD
  }

  Manager.Targets[id] = target
  Manager.Spawn(id)
end

--- Spawns the target group.
function Manager.Spawn(id)
  local t = Manager.Targets[id]
  if not t then return end

  local pos = t.Coord:GetVec2()
  DCS.MIS.SpawnGroup(t.ID, t.Template, pos, t.Heading or 0, coalition.side.RED)
  local group = Group.getByName(t.ID)
  
  if group then
    t.Group = group
    t.State = "ALIVE"
    t.DeadTime = nil
    env.info("DCS.MIS.StrikeManager: Spawned target " .. t.ID)
  else
    env.error("DCS.MIS.StrikeManager: Failed to spawn target " .. t.ID)
  end
end

-- Monitoring Loop
local function MonitorTargets(arg, time)
  for id, t in pairs(Manager.Targets) do
    if t.State == "ALIVE" and (not t.Group or not t.Group:IsAlive()) then
      t.State = "DEAD"
      t.DeadTime = timer.getTime()
      env.info("DCS.MIS.StrikeManager: Target " .. id .. " destroyed. Regenerating in " .. t.RegenTime .. "s.")
    elseif t.State == "DEAD" and timer.getTime() >= (t.DeadTime + t.RegenTime) then
      env.info("DCS.MIS.StrikeManager: Regenerating target " .. id)
      Manager.Spawn(id)
    end
  end
  return time + 10 -- Check every 10 seconds
end

-- Start loop
timer.scheduleFunction(MonitorTargets, nil, timer.getTime() + 5)

env.info("DCS.MIS(CORE): ready")