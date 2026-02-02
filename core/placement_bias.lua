
env.info("TCS(A2G.PLACEMENT_BIAS): loading")

TCS.A2G.PlacementBias = {}

function TCS.A2G.PlacementBias.Resolve(baseCoord, missionType)
  if missionType == "SEAD" then
    return baseCoord:Translate(500, math.random(0,359))
  end
  if missionType == "BAI" then
    return baseCoord:Translate(1000, math.random(0,359))
  end
  return baseCoord
end

env.info("TCS(A2G.PLACEMENT_BIAS): ready")
