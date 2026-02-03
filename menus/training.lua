---------------------------------------------------------------------
-- menus/training.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading TRAINING")

function TCS.Menu.BuildTraining(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end
  -- placeholder for future ACM/BFM training expansion

  -- 1. A2A (ACM & BFM)
  local a2a = MENU_GROUP:New(rec.Group, "A2A Training", root.TRAINING)

  -- 1a. Target Drone
  MENU_GROUP_COMMAND:New(rec.Group, "Target Drone (No Threat)", a2a, function()
    if TCS.A2A.Training.StartDrone then TCS.A2A.Training.StartDrone(rec.Group) end
  end)

  -- 1b. Guns Only
  local guns = MENU_GROUP:New(rec.Group, "Guns Only (WVR)", a2a)
  MENU_GROUP_COMMAND:New(rec.Group, "H2H (Neutral)", guns, function() TCS.A2A.Training.StartH2HDogFight(rec.Group, "GUNS") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Abeam (Offensive)", guns, function() TCS.A2A.Training.StartABEAMDogFight(rec.Group, "GUNS") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Defensive", guns, function() TCS.A2A.Training.StartDefensiveDogFight(rec.Group, "GUNS") end)

  -- 1c. Fox 2
  local fox2 = MENU_GROUP:New(rec.Group, "Fox 2 (WVR)", a2a)
  MENU_GROUP_COMMAND:New(rec.Group, "H2H (Neutral)", fox2, function() TCS.A2A.Training.StartH2HDogFight(rec.Group, "FOX2") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Abeam (Offensive)", fox2, function() TCS.A2A.Training.StartABEAMDogFight(rec.Group, "FOX2") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Defensive", fox2, function() TCS.A2A.Training.StartDefensiveDogFight(rec.Group, "FOX2") end)

  -- 1d. Fox 1 (BVR)
  local fox1 = MENU_GROUP:New(rec.Group, "Fox 1 (BVR)", a2a)
  MENU_GROUP_COMMAND:New(rec.Group, "BVR Single", fox1, function()
    if TCS.A2A.Training.StartBVR then TCS.A2A.Training.StartBVR(rec.Group, "FOX1") end
  end)

  -- 1e. Fox 3 (BVR)
  local fox3 = MENU_GROUP:New(rec.Group, "Fox 3 (BVR)", a2a)
  MENU_GROUP_COMMAND:New(rec.Group, "BVR Single", fox3, function()
    if TCS.A2A.Training.StartBVR then TCS.A2A.Training.StartBVR(rec.Group, "FOX3") end
  end)

  -- 2. A2G Ranges
  local a2g = MENU_GROUP:New(rec.Group, "A2G Ranges", root.TRAINING)

  MENU_GROUP_COMMAND:New(rec.Group, "Build Bomb Range", a2g, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "BOMB")
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Build Strafe Pit", a2g, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "STRAFE")
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Build Mixed Range", a2g, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "MIXED")
    end
  end)

  local mov = MENU_GROUP:New(rec.Group, "Build Moving Range", a2g)

  MENU_GROUP_COMMAND:New(rec.Group, "Passive (Trucks)", mov, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "MOVING")
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Hostile (Armor)", mov, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "MOVING_HOSTILE")
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Build Pop-up Threat", a2g, function()
    if A2G_RANGE and A2G_RANGE.Build then
      A2G_RANGE.Build(rec.Group:GetName(), rec.Unit:GetName(), "POPUP")
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Reset Range", a2g, function()
    if A2G_RANGE and A2G_RANGE.Reset then
      A2G_RANGE.Reset(rec.Group:GetName())
    end
  end)
end
