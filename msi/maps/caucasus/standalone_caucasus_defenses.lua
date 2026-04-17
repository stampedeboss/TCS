---------------------------------------------------------------------
-- STANDALONE CAUCASUS DEFENSES
--
-- Purpose:
--   Spawns historical SAM placements and Red Air CAPs for the
--   Caucasus map at mission start.
--
-- Usage:
--   Add a "MISSION START" trigger that runs "DO SCRIPT FILE"
--   and points to this script.
--
-- Notes:
--   This script is self-contained and does not require TCS or
--   any other libraries to function.
---------------------------------------------------------------------

-- Only run on Caucasus map
if env.mission.theatre ~= "Caucasus" then
  env.info("Standalone Defenses: Not Caucasus map, script will not run.")
  return
end

env.info("Standalone Defenses: Initializing for Caucasus...")

--- UTILITY: Calculate a point relative to a named point (bearing in degrees, dist in NM)
local function GetRelativePoint(baseName, bearing, distNM)
 local ab = Airbase.getByName(baseName)
 if not ab then
    env.warning("Standalone Defenses: Could not find reference airbase: " .. baseName)
   return nil
  end
  
  local p = ab:getPoint() -- Vec3
  local distM = distNM * 1852
  local rad = math.rad(bearing)
  
  return {
    x = p.x + math.cos(rad) * distM,
    y = p.z + math.sin(rad) * distM -- Note: DCS Vec3.z is Map Y
  }
end

-- DEFINITIONS: SAM and CAP placements
local Defenses = {
  SAMs = {
    -- Strategic (SA-10 / S-300)
    { Name = "SAM_Mozdok_S300",   Type = "S-300",  Ref = "Mozdok",          Bearing = 90,  Dist = 2 },
    { Name = "SAM_Krasnodar_S300",Type = "S-300",  Ref = "Krasnodar-Pashkovsky", Bearing = 270, Dist = 3 },
    
    -- Operational (SA-11 / Buk)
    { Name = "SAM_Nalchik_Buk",   Type = "SA-11",  Ref = "Nalchik",         Bearing = 180, Dist = 1.5 },
    { Name = "SAM_Maykop_Buk",    Type = "SA-11",  Ref = "Maykop-Khanskaya",Bearing = 0,   Dist = 2 },
    { Name = "SAM_Sochi_Buk",     Type = "SA-11",  Ref = "Sochi-Adler",     Bearing = 45,  Dist = 4 },

    -- Tactical (SA-15 / Tor or SA-8 / Osa)
    { Name = "SAM_Gudauta_Tor",   Type = "SA-15",  Ref = "Gudauta",         Bearing = 315, Dist = 1 },
    { Name = "SAM_Sukhumi_Osa",   Type = "SA-8",   Ref = "Sukhumi-Babushara", Bearing = 90, Dist = 1 },
  },

  CAP = {
    { 
      Name = "CAP_RED_EAST",
      Ref = "Beslan",
      Bearing = 90,
      Dist = 20,
      Type = "Su-27",
      Alt = 26000,
      PatrolLen = 30
    },
    { 
      Name = "CAP_RED_WEST",
      Ref = "Krasnodar-Center",
      Bearing = 180,
      Dist = 30,
      Type = "MiG-29S",
      Alt = 22000,
      PatrolLen = 25
    }
  }
}

-- DEFINITIONS: Unit templates for spawning
local Templates = {
  ["S-300"] = {
    category = Group.Category.GROUND,
    units = {"S-300PS 40B6M tr", "S-300PS 40B6MD sr", "S-300PS 5P85C ln", "S-300PS 5P85C ln", "S-300PS 5P85D ln", "S-300PS 5P85D ln", "S-300PS 64H6E sr"}
  },
  ["SA-11"] = {
    category = Group.Category.GROUND,
    units = {"SA-11 Buk SR 9S18M1", "SA-11 Buk CC 9S470M1", "SA-11 Buk LN 9A310M1", "SA-11 Buk LN 9A310M1", "SA-11 Buk LN 9A310M1", "SA-11 Buk LN 9A310M1"}
  },
  ["SA-15"] = {
    category = Group.Category.GROUND,
    units = {"Tor 9A331", "Tor 9A331", "Tor 9A331", "Tor 9A331"}
  },
  ["SA-8"] = {
    category = Group.Category.GROUND,
    units = {"Osa 9A33", "Osa 9A33", "Osa 9A33", "Osa 9A33"}
  }
}

-- HELPER: Spawns a group from a template
local function SpawnGroup(name, template, pos, heading)
  local groupData = {
    name = name,
    task = template.category == Group.Category.AIRPLANE and "CAP" or "Ground Nothing",
    units = {}
  }

  for i, unitType in ipairs(template.units) do
    local xOffset = (i-1) * 20
    table.insert(groupData.units, {
      name = name .. "_U" .. i,
      type = unitType,
      x = pos.x + xOffset,
      y = pos.y + xOffset,
      heading = math.rad(heading),
      skill = "High"
    })
  end

  if template.route then
    groupData.route = template.route
  end

  coalition.addGroup(coalition.side.RED, template.category, groupData)
end

-- MAIN LOGIC: Spawn all defined assets
local function SpawnAllDefenses()
  env.info("Standalone Defenses: Spawning assets...")

  -- Spawn SAMs
  for _, sam in ipairs(Defenses.SAMs) do
    local p = GetRelativePoint(sam.Ref, sam.Bearing, sam.Dist)
    if p and Templates[sam.Type] then
      SpawnGroup(sam.Name, Templates[sam.Type], p, 0)
      env.info("Standalone Defenses: Spawned " .. sam.Type .. " at " .. sam.Name)
    end
  end

  -- Spawn CAPs
  for _, cap in ipairs(Defenses.CAP) do
    local p = GetRelativePoint(cap.Ref, cap.Bearing, cap.Dist)
    if p then
      local startPt = {x = p.x, y = p.y}
      local endPt = {x = p.x + (cap.PatrolLen * 1852), y = p.y} -- Simple East offset
      local route = { points = { [1] = { x = startPt.x, y = startPt.y, alt = cap.Alt * 0.3048, type = "Turning Point", action = "Turning Point", speed = 250, task = { id = "ComboTask", params = { tasks = { [1] = { id = "EngageTargets", params = { maxDist = 40000, targetTypes = {"Air"} } } } } } }, [2] = { x = endPt.x, y = endPt.y, alt = cap.Alt * 0.3048, type = "Turning Point", action = "Turning Point", speed = 250 } } }
      local template = { category = Group.Category.AIRPLANE, units = {cap.Type, cap.Type}, route = route }
      SpawnGroup(cap.Name, template, startPt, 90)
      env.info("Standalone Defenses: Spawned CAP " .. cap.Name)
    end
  end
end

-- EXECUTION: Run the spawn logic
SpawnAllDefenses()

env.info("Standalone Defenses: Initialization complete.")