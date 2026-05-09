TCS = TCS or {}
TCS.RANGE = TCS.RANGE or {}

function TCS.RANGE.BuildPattern(pattern, center, hdgRad, cfg)
  local pts = {}
  local spacing = cfg.spacing_m or 25
  local cx = center.x
  local cz = center.z -- MOOSE coord .z is Map Y

  if pattern == "ROW" then
    for i = 1, cfg.count do
      local dist = (i - 1) * spacing
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
      table.insert(pts, {
        x = cx + math.cos(a) * spacing,
        z = cz + math.sin(a) * spacing
      })
    end

  elseif pattern == "GRID" then
    local rows = cfg.rows or 3
    local cols = cfg.columns or 3
    -- Center the grid
    local offX = (cols - 1) * spacing / 2
    local offZ = (rows - 1) * spacing / 2
    
    for r = 1, rows do
      for c = 1, cols do
        local dx = (c - 1) * spacing - offX
        local dz = (r - 1) * spacing - offZ
        -- Rotate
        local rx = dx * math.cos(hdgRad) - dz * math.sin(hdgRad)
        local rz = dx * math.sin(hdgRad) + dz * math.cos(hdgRad)
        
        table.insert(pts, {
          x = cx + rx,
          z = cz + rz
        })
      end
    end

  elseif pattern == "RANDOM" then
    local count = cfg.count or 10
    local radius = cfg.radius or (spacing * 5)
    for i = 1, count do
      local r = math.sqrt(math.random()) * radius
      local a = math.random() * 2 * math.pi
      table.insert(pts, {
        x = cx + math.cos(a) * r,
        z = cz + math.sin(a) * r
      })
    end
  end

  return pts
end
