---------------------------------------------------------------------
-- DCS.MIS: CAUCASUS DEFENSES
-- Historical SAM placement and Red Air CAP zones.
---------------------------------------------------------------------
env.info("DCS.MIS: Loading Caucasus Defenses")

_G.DCS = _G.DCS or {}
_G.DCS.MIS = _G.DCS.MIS or {}
_G.DCS.MIS.Caucasus = _G.DCS.MIS.Caucasus or {}

-- 1. Defense Definitions
DCS.MIS.Caucasus.Defenses = {
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

-- 2. Templates
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

-- 3. Initialization Logic
function DCS.MIS.Caucasus.InitDefenses()
  env.info("DCS.MIS: Spawning Caucasus Defenses...")

  -- Spawn SAMs
  for _, sam in ipairs(DCS.MIS.Caucasus.Defenses.SAMs) do
    local p = DCS.GetRelativePoint(sam.Ref, sam.Bearing, sam.Dist)
    if p and Templates[sam.Type] then
      DCS.MIS.SpawnGroup(sam.Name, Templates[sam.Type], p, 0)
      env.info("DCS.MIS: Spawned " .. sam.Type .. " at " .. sam.Name)
    end
  end

  -- Spawn CAPs
  for _, cap in ipairs(DCS.MIS.Caucasus.Defenses.CAP) do
    local p = DCS.GetRelativePoint(cap.Ref, cap.Bearing, cap.Dist)
    if p then
      local startPt = {x = p.x, y = p.y}
      local endPt = {x = p.x + (cap.PatrolLen * 1852), y = p.y} -- Simple East offset
      
      local route = {
        points = {
          [1] = {
            x = startPt.x,
            y = startPt.y,
            alt = cap.Alt * 0.3048,
            type = "Turning Point",
            action = "Turning Point",
            speed = 250,
            task = { id = "ComboTask", params = { tasks = { [1] = { id = "EngageTargets", params = { maxDist = 40000, targetTypes = {"Air"} } } } } }
          },
          [2] = {
            x = endPt.x,
            y = endPt.y,
            alt = cap.Alt * 0.3048,
            type = "Turning Point",
            action = "Turning Point",
            speed = 250
          }
        }
      }

      local template = {
        category = Group.Category.AIRPLANE,
        units = {cap.Type, cap.Type},
        route = route
      }
      
      DCS.MIS.SpawnGroup(cap.Name, template, startPt, 90)
      env.info("DCS.MIS: Spawned CAP " .. cap.Name)
    end
  end
end

-- Auto-execute if map matches
if env.mission.theatre == "Caucasus" then
  DCS.MIS.Caucasus.InitDefenses()
end