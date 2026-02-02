---------------------------------------------------------------------
-- menus/training.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading TRAINING")

function TCS_MENU.BuildTraining(rec)
  local g = rec.Group:GetName()
  local root = TCS_MENU.Groups[g]
  if not root then return end
  -- placeholder for future ACM/BFM training expansion
end
