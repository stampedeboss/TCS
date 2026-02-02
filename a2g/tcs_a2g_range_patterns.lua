function TCS.RANGE:BuildPattern(pattern, center, hdg, cfg)
  local pts = {}
  local spacing = cfg.spacing_m or 25

  if pattern == "ROW" then
    for i = 1, cfg.count do
      table.insert(pts, {
        x = center.x + (i - 1) * spacing * math.cos(hdg),
        z = center.z + (i - 1) * spacing * math.sin(hdg)
      })
    end

  elseif pattern == "STAR" then
    local angleStep = (2 * math.pi) / cfg.count
    for i = 1, cfg.count do
      local a = angleStep * i
      table.insert(pts, {
        x = center.x + math.cos(a) * spacing,
        z = center.z + math.sin(a) * spacing
      })
    end

  elseif pattern == "GRID" then
    for r = 1, cfg.rows do
      for c = 1, cfg.columns do
        table.insert(pts, {
          x = center.x + (c - 1) * spacing,
          z = center.z + (r - 1) * spacing
        })
      end
    end
  end

  return pts
end
