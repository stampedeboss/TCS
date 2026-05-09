env.info("TCS(CONFIG): loading")

TCS = TCS or {}
TCS.Config = TCS.Config or {}

-- Core Settings
TCS.Config.Coalition = coalition.side.BLUE

-- Resolve SRS Port based on Server Instance
local srs_port = 5002
if lfs then
  local path = lfs.writedir()
  if string.find(path, 'StampedesPlayground') then srs_port = 5002
  elseif string.find(path, 'FlyingWrecksAlpha') then srs_port = 15002
  elseif string.find(path, 'FlyingWrecksBravo') then srs_port = 15003
  elseif string.find(path, 'FlyingWrecksCharlie') then srs_port = 15004
  end
end

-- AWACS (SRS) - Elevated to Core
TCS.Config.AWACS = {
  Label = "DARKSTAR", Freq = 251.000, Mod = radio.modulation.AM,
  SRSPath = [[C:\ProgramData\DCS-SimpleRadio-Standalone]],
  Port = srs_port,
  Gender = "female", Culture = "en-US",
  UpdateTotal = 180, UpdateEvery = 30,
}

-- Echelons (Scaling & Difficulty Tier)
TCS.Config.Echelons = {
  PLATOON   = { scale=1,  spacing=30, tier="A" },
  COMPANY   = { scale=3,  spacing=50, tier="G" },
  BATTALION = { scale=5,  spacing=75, tier="H" },
  BRIGADE   = { scale=7, spacing=100, tier="X" },
  -- Sea
  SEA_PATROL = { scale=1, spacing=4000, tier="A" },
  TASK_UNIT  = { scale=2, spacing=1000, tier="G" },
  TASK_GROUP = { scale=3, spacing=2000, tier="H" },
  TASK_FORCE = { scale=4, spacing=4000, tier="X" },
  -- Air
  PATROL       = { scale=2, spacing=4000, tier="A" },
  SQUADRON     = { scale=4, spacing=1000, tier="G" },
  WING         = { scale=5, spacing=2000, tier="H" },
  AIR_DIVISION = { scale=6, spacing=4000, tier="X" }
}

TCS.Config.DifficultyMap = {
  [1] = { LAND="PLATOON",   SEA="SEA_PATROL", AIR="PATROL" },
  [2] = { LAND="COMPANY",   SEA="TASK_UNIT",  AIR="SQUADRON" },
  [3] = { LAND="BATTALION", SEA="TASK_GROUP", AIR="WING" },
  [4] = { LAND="BRIGADE",   SEA="TASK_FORCE", AIR="AIR_DIVISION" },
}

-- 476 Range Targets Fallback (Mod missing support)
TCS.Config.CatalogFallbacks = {
  ["476_Target_Circle_75"]       = "Container Red 1",
  ["476_Target_Circle_150"]      = "Container Red 1",
  ["476_Target_Square_75"]       = "Container Red 2",
  ["476_Target_Square_150"]      = "Container Red 2",
  ["476_Target_Hard_1"]          = "Bunker",
  ["476_Conex_Box_White"]        = "Container Red 3",
  ["476_Target_Truck"]           = "Container Red 1",
  ["476_Target_APC"]             = "Container Red 1",
  ["476_Target_Tank"]            = "Container Red 1",
  ["476_Target_Strafe_Pit_West"] = "Container Red 1",
  ["476_Target_Strafe_Pit_East"] = "Container Red 1",
  ["476_Target_Panel_Vertical"]  = "Container Red 1",
}

-- Admin UCIDs (Server Admins)
-- If empty, ALL players can use admin commands (Dev Mode).
-- Add UCIDs strings here to restrict access.
TCS.Config.Admins = {
  "9206bc8a296341b4d1610f4bd5ecad6b",
}


env.info("TCS(CONFIG): ready")