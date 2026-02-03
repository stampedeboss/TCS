
env.info("TCS(A2G.SPAWN_SPACING): loading")

TCS.SpawnSpacing = {}

local function getSpacing(spacingClass)
  if spacingClass == "TIGHT" then return 20 end
  if spacingClass == "PLATOON" then return 50 end
  if spacingClass == "COMPANY" then return 100 end
  return 30 -- default
end

function TCS.SpawnSpacing.GetPoints(pattern, count, spacingClass)
  local spacing = getSpacing(spacingClass)
  local points = {}

  if pattern == "COLUMN" then
    for i = 1, count do
      table.insert(points, { x = 0, y = -(i - 1) * spacing })
    end
  elseif pattern == "ROW" then
    local half = (count - 1) / 2
    for i = 1, count do
      table.insert(points, { x = (i - 1 - half) * spacing, y = 0 })
    end
  elseif pattern == "VEE" then
    table.insert(points, { x = 0, y = 0 }) -- Leader
    for i = 2, count do
      local side = (i % 2 == 0) and 1 or -1
      local rank = math.floor((i-1)/2)
      table.insert(points, { x = side * rank * spacing, y = -rank * spacing })
    end
  else -- Default to COLUMN
    for i = 1, count do
      table.insert(points, { x = 0, y = -(i - 1) * spacing })
    end
  end

  return points
end

env.info("TCS(A2G.SPAWN_SPACING): ready")
