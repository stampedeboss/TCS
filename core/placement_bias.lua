---------------------------------------------------------------------
-- TCS PLACEMENT BIAS
-- Adjusts anchor points based on tactical context (TAG)
---------------------------------------------------------------------
env.info("TCS(PLACEMENT_BIAS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.PlacementBias = {}

--- Resolves a biased position for a specific capability tag.
-- @param anchor (Coordinate) The reference coordinate.
-- @param tag (string) The capability tag (e.g. "BAI", "SAM").
-- @return (Coordinate) The biased coordinate.
function TCS.A2G.PlacementBias.Resolve(anchor, tag)
  if not anchor then return nil end
  -- Default: Return original anchor (Pass-through)
  -- Future logic: Find nearest road for convoys, hilltops for SAMs, etc.
  return anchor
end

env.info("TCS(PLACEMENT_BIAS): ready")