---------------------------------------------------------------------
-- TCS PLACEMENT BIAS
-- Adjusts anchor points based on mission type intent
---------------------------------------------------------------------
env.info("TCS(PLACEMENT_BIAS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.PlacementBias = {}

function TCS.A2G.PlacementBias.Resolve(anchor, tag)
  if not anchor then return nil end
  
  -- Default: No bias
  local biased = anchor

  if tag == "SEAD" or tag == "DEAD" then
    -- Offset slightly to create a distinct threat cluster, 
    -- potentially separating it from the main target body
    biased = anchor:Translate(2000, math.random(0, 359))
  elseif tag == "BAI" then
    -- BAI targets might be spread out along a road or axis
    -- For now, we keep them central to the anchor
    biased = anchor
  elseif tag == "STRIKE" then
    -- Strike targets are precise
    biased = anchor
  end

  return biased
end

env.info("TCS(PLACEMENT_BIAS): ready")