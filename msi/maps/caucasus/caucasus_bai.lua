---------------------------------------------------------------------
-- DCS.MIS: CAUCASUS BAI
-- Persistent BAI zones with patrolling and static units.
---------------------------------------------------------------------
env.info("DCS.MIS: Loading Caucasus BAI")

_G.DCS = _G.DCS or {}
_G.DCS.MIS = _G.DCS.MIS or {}
_G.DCS.MIS.Caucasus = _G.DCS.MIS.Caucasus or {}

-- 1. BAI Definitions
DCS.MIS.Caucasus.BAI = {
  Zones = {
    {
      Name = "BAI_Maykop_South",
      Ref = "Maykop-Khanskaya",
      Bearing = 180,
      Dist = 20,
      Patrols = {
        { Type = "Armor_Platoon", Count = 2, Radius = 3 },
        { Type = "Convoy_Supply", Count = 1, Radius = 5 }
      },
      Statics = {
        { Type = "Command_Post", Count = 1 },
        { Type = "Logistics_Hub", Count = 1 }
      }
    }
  }
}

-- 2. Templates
local Templates = {
  ["Armor_Platoon"] = {
    category = Group.Category.GROUND,
    units = {"T-72B", "BMP-2", "BMP-2", "ZSU-23-4 Shilka"}
  },
  ["Convoy_Supply"] = {
    category = Group.Category.GROUND,
    units = {"Ural-375", "Ural-375", "Ural-375", "BTR-80"}
  },
  ["Command_Post"] = {
    category = Group.Category.GROUND,
    units = {"SKP-11", "Gaz-66"}
  },
  ["Logistics_Hub"] = {
    category = Group.Category.GROUND,
    units = {"Ural-4320T", "Ural-4320T", "ATMZ-5", "Kamaz 43101"}
  }
}

-- 3. Initialization Logic
function DCS.MIS.Caucasus.InitBAI()
  env.info("DCS.MIS: Spawning Caucasus BAI Zones...")

  for _, zone in ipairs(DCS.MIS.Caucasus.BAI.Zones) do
    local center = DCS.GetRelativePoint(zone.Ref, zone.Bearing, zone.Dist)
    if center then
      env.info("DCS.MIS: Initializing BAI Zone: " .. zone.Name)

      -- Spawn Patrols
      if zone.Patrols then
        for i, patrol in ipairs(zone.Patrols) do
          local tpl = Templates[patrol.Type]
          if tpl then
            for j = 1, patrol.Count do
              local r = math.random() * (patrol.Radius * 1852)
              local theta = math.rad(math.random(0, 359))
              local p = {
                x = center.x + r * math.cos(theta),
                y = center.y + r * math.sin(theta)
              }
              
              -- Create a simple patrol route
              local route = {
                points = {
                  [1] = { x = p.x, y = p.y, action = "Off Road", speed = 20, type = "Turning Point", task = { id = "ComboTask", params = { tasks = {} } } },
                  [2] = { x = p.x + (math.random() > 0.5 and 2000 or -2000), y = p.y + (math.random() > 0.5 and 2000 or -2000), action = "Off Road", speed = 20, type = "Turning Point" }
                }
              }
              
              local spawnTpl = { category = tpl.category, units = tpl.units, route = route }
              local name = string.format("%s_Patrol_%d_%d", zone.Name, i, j)
              DCS.MIS.SpawnGroup(name, spawnTpl, p, math.random(0, 359), coalition.side.RED)
            end
          end
        end
      end

      -- Spawn Statics
      if zone.Statics then
        for i, staticDef in ipairs(zone.Statics) do
          local tpl = Templates[staticDef.Type]
          if tpl then
            for j = 1, staticDef.Count do
               local r = math.random() * 1000
               local theta = math.rad(math.random(0, 359))
               local p = { x = center.x + r * math.cos(theta), y = center.y + r * math.sin(theta) }
               local name = string.format("%s_Static_%d_%d", zone.Name, i, j)
               DCS.MIS.SpawnGroup(name, tpl, p, math.random(0, 359), coalition.side.RED)
            end
          end
        end
      end
    end
  end
end

-- Auto-execute if map matches
if env.mission.theatre == "Caucasus" then
  DCS.MIS.Caucasus.InitBAI()
end