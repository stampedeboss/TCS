---------------------------------------------------------------------
-- TCS TOWER: TRAINING
-- Domain Specialist: Pattern generation for ranges (Bombing/Strafing).
---------------------------------------------------------------------
env.info("TCS(TOWER.TRAINING): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Training = {}

--- Builds a coordinate pattern relative to a center point.
function TCS.Towers.Training.BuildPattern(pattern, center, hdgRad, cfg)
  local pts = {}
  local spacing = cfg.spacing_m or 25
  local cx = center.x
  local cz = center.z or center.y -- Map Y

  if pattern == "ROW" then
    local half = (cfg.count - 1) / 2
    for i = 1, cfg.count do
      local dist = (i - 1 - half) * spacing
      table.insert(pts, {
        x = cx + dist * math.cos(hdgRad),
        z = cz + dist * math.sin(hdgRad)
      })
    end
  elseif pattern == "STAR" then
    local count = cfg.count or 5
    local angleStep = (2 * math.pi) / count
    for i = 1, count do
      local a = angleStep * i + hdgRad
      table.insert(pts, { x = cx + math.cos(a) * spacing, z = cz + math.sin(a) * spacing })
    end
  elseif pattern == "GRID" then
    local rows = cfg.rows or 3; local cols = cfg.columns or 3
    local offX = (cols - 1) * spacing / 2; local offZ = (rows - 1) * spacing / 2
    for r = 1, rows do
      for c = 1, cols do
        local dx = (c - 1) * spacing - offX; local dz = (r - 1) * spacing - offZ
        local rx = dx * math.cos(hdgRad) - dz * math.sin(hdgRad)
        local rz = dx * math.sin(hdgRad) + dz * math.cos(hdgRad)
        table.insert(pts, { x = cx + rx, z = cz + rz })
      end
    end
  elseif pattern == "RANDOM" then
    local count = cfg.count or 10; local radius = cfg.radius or (spacing * 5)
    for i = 1, count do
      local r = math.sqrt(math.random()) * radius; local a = math.random() * 2 * math.pi
      table.insert(pts, { x = cx + math.cos(a) * r, z = cz + math.sin(a) * r })
    end
  end
  return pts
end

--- Translates a training request into a Range Recipe.
function TCS.Towers.Training.GetRecipe(rangeKey, centerCoord, playerHdgRad)
  local rangeDef = TCS.Config.A2G.Range[rangeKey]
  if not rangeDef then return nil end

  local pattern = rangeDef.pattern or "RANDOM"
  local coords = TCS.Towers.Training.BuildPattern(pattern, centerCoord, playerHdgRad, rangeDef)
  
  return {
    tower = "TRAINING",
    rangeKey = rangeKey,
    activity = rangeDef.activity, -- CONVOY, POPUP, BOMB, STRAFE, MIXED
    purpose = rangeDef.purpose,   -- BOMB, STRAFE, MIXED
    targetPool = rangeDef.target_pool,
    coords = coords,
    heading = playerHdgRad + math.pi,
    geometry = {
        center = centerCoord,
        heading = playerHdgRad
    }
  }
end

env.info("TCS(TOWER.TRAINING): ready")