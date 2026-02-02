
env.info("TCS(A2G.SPAWN_SPACING): loading")

TCS.A2G.SpawnSpacing = {}

function TCS.A2G.SpawnSpacing.Offset(anchor, index, spacing)
  return anchor:Translate(index * spacing, math.random(0,359))
end

env.info("TCS(A2G.SPAWN_SPACING): ready")
