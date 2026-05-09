---------------------------------------------------------------------
-- TCS TOWER: LAND TRAINING
-- Domain Specialist: Pattern generation for ranges (Bombing/Strafing).
---------------------------------------------------------------------
env.info("TCS(TOWER.LAND.TRAINING): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Land = TCS.Towers.Land or {}
TCS.Towers.Land.Training = {}

--- Builds a relative coordinate blueprint (offsets only, no absolute map coordinates).
function TCS.Towers.Land.Training.BuildRelativeBlueprint(pattern, cfg)
  local pts = {}
  local spacing = cfg.spacing_m or 25

  if pattern == "ROW" then
    local half = (cfg.count - 1) / 2
    for i = 1, cfg.count do
      table.insert(pts, { x = 0, y = (i - 1 - half) * spacing }) -- Relative offset
    end
  elseif pattern == "STAR" then
    local count = cfg.count or 5
    local angleStep = (2 * math.pi) / count
    for i = 1, count do
      local a = angleStep * i
      table.insert(pts, { x = math.cos(a) * spacing, y = math.sin(a) * spacing })
    end
  elseif pattern == "GRID" then
    local rows = cfg.rows or 3; local cols = cfg.columns or 3
    local offX = (cols - 1) * spacing / 2; local offY = (rows - 1) * spacing / 2
    for r = 1, rows do
      for c = 1, cols do
        table.insert(pts, { x = (c - 1) * spacing - offX, y = (r - 1) * spacing - offY })
      end
    end
  elseif pattern == "RANDOM" then
    local count = cfg.count or 10; local radius = cfg.radius or (spacing * 5)
    for i = 1, count do
      local r = math.sqrt(math.random()) * radius; local a = math.random() * 2 * math.pi
      table.insert(pts, { x = math.cos(a) * r, y = math.sin(a) * r })
    end
  end
  
  -- Provide a single point for basic layouts if count was undefined
  if #pts == 0 then
      table.insert(pts, { x = 0, y = 0 })
  end
  return pts
end

--- Translates a training request into a relative Architect Blueprint.
function TCS.Towers.Land.Training.GetRecipe(rangeKey, anchorCoord, ingressHdgRad)
  local rangeDef = TCS.Land and TCS.Land.Config and TCS.Land.Config.Range and TCS.Land.Config.Range[rangeKey]
  if not rangeDef then return nil end

  local pattern = rangeDef.pattern or "RANDOM"
  local relativeOffsets = TCS.Towers.Land.Training.BuildRelativeBlueprint(pattern, rangeDef)
  
  return {
    tower = "LAND",
    rangeKey = rangeKey,
    activity = rangeDef.activity, -- CONVOY, POPUP, BOMB, STRAFE, MIXED
    purpose = rangeDef.purpose,   -- BOMB, STRAFE, MIXED
    targetPool = rangeDef.target_pool,
    blueprint = relativeOffsets,
    geometry = {
        type = "ANCHORED",
        anchor = anchorCoord,
        ingressHdg = ingressHdgRad
    }
  }
end

env.info("TCS(TOWER.LAND.TRAINING): ready")