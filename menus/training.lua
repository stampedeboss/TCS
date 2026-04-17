---------------------------------------------------------------------
-- menus/training.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading TRAINING")

function TCS.Menu.BuildTraining(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end
  -- placeholder for future ACM/BFM training expansion

  -- =========================================================
  -- 1. AIR (A2A)
  -- =========================================================
  local air = MENU_GROUP:New(rec.Group, "Air (A2A)", root.TRAINING)

  -- 1a. ACM (Guns Only, Close-in)
  local acm = MENU_GROUP:New(rec.Group, "ACM (Guns Only)", air)
  MENU_GROUP_COMMAND:New(rec.Group, "H2H (Neutral)", acm, function() 
    if TCS.API and TCS.API.CreateA2ATraining_H2H then TCS.API.CreateA2ATraining_H2H({ group = rec.Group, mode = "GUNS" }) end 
  end)
  MENU_GROUP_COMMAND:New(rec.Group, "Abeam (Offensive)", acm, function() 
    if TCS.API and TCS.API.CreateA2ATraining_Abeam then TCS.API.CreateA2ATraining_Abeam({ group = rec.Group }) end 
  end)
  MENU_GROUP_COMMAND:New(rec.Group, "Defensive", acm, function() 
    if TCS.API and TCS.API.CreateA2ATraining_Defensive then TCS.API.CreateA2ATraining_Defensive({ group = rec.Group }) end 
  end)

  -- 1b. BFM (Missiles Allowed, Maneuvering)
  local bfm = MENU_GROUP:New(rec.Group, "BFM (Missiles)", air)
  -- For now, mapping these to the existing Fox2/BVR logic but framing them as BFM setups
  MENU_GROUP_COMMAND:New(rec.Group, "Fox 2 (WVR)", bfm, function() 
    if TCS.API and TCS.API.CreateA2ATraining_H2H then TCS.API.CreateA2ATraining_H2H({ group = rec.Group, mode = "FOX2" }) end 
  end)
  MENU_GROUP_COMMAND:New(rec.Group, "BVR Intercept", bfm, function() 
    -- BVR training re-uses the standard Intercept logic
    if TCS.API and TCS.API.CreateIntercept then TCS.API.CreateIntercept({ group = rec.Group }) end 
  end)
  
  -- 1c. Drone
  MENU_GROUP_COMMAND:New(rec.Group, "Target Drone", air, function()
    if TCS.API and TCS.API.CreateA2ATraining_Drone then
      TCS.API.CreateA2ATraining_Drone({ group = rec.Group })
    end
  end)

  -- =========================================================
  -- 2. GROUND (A2G)
  -- =========================================================
  local ground = MENU_GROUP:New(rec.Group, "Ground (A2G)", root.TRAINING)
  
  -- Check if player is over water to build a context-aware menu
  local isOverWater = false
  local p = rec.Unit and rec.Unit:GetVec3()
  if p and land.getSurfaceType({x=p.x, y=p.z}) == land.SurfaceType.WATER then
    isOverWater = true
  end

  -- Helper function to create the final menu command
  local function addRange(parent, label, configKey)
    MENU_GROUP_COMMAND:New(rec.Group, label, parent, function()
      if TCS.API and TCS.API.CreateRange then
        TCS.API.CreateRange({ group = rec.Group, config = configKey })
      end
    end)
  end
  
  -- 2a. Bombs (Fixed Targets)
  local bombs = MENU_GROUP:New(rec.Group, "Bombs", ground)
  if isOverWater then
    addRange(bombs, "Row (Shipping)", "bomb_row_shipping")
  else
    addRange(bombs, "Row (Containers)", "bomb_row_containers")
    addRange(bombs, "Row (476 Circles)", "bomb_row_476_circles")
    addRange(bombs, "Star (Containers)", "bomb_star_containers")
    addRange(bombs, "Grid (Random)", "bomb_grid_random")
  end

  -- 2b. Guns (Strafe)
  local guns = MENU_GROUP:New(rec.Group, "Guns", ground)
  if isOverWater then
    addRange(guns, "Row (Shipping)", "strafe_row_shipping")
  else
    addRange(guns, "Strafe Pit (476)", "range_476_strafe")
    addRange(guns, "Soft Row (Trucks)", "strafe_row_generic")
    addRange(guns, "Hard Row (Armor)", "strafe_row_armor")
  end

  -- 2c. Rockets (Soft/Area Targets)
  local rockets = MENU_GROUP:New(rec.Group, "Rockets", ground)
  if not isOverWater then
    addRange(rockets, "Soft Grid (Trucks)", "rocket_grid_soft")
    addRange(rockets, "Mixed Grid", "mixed_grid")
  end

  -- 2d. Missiles (Mobile/Fixed/Radar)
  local missiles = MENU_GROUP:New(rec.Group, "Missiles", ground)
  local m_mobile = MENU_GROUP:New(rec.Group, "Mobile", missiles)
  if not isOverWater then
    addRange(m_mobile, "Convoy Hunt", "convoy_hunt")
    addRange(m_mobile, "Moving Armor", "MOVING_HOSTILE")
  end
  
  local m_fixed = MENU_GROUP:New(rec.Group, "Fixed/Pop-up", missiles)
  if isOverWater then
    addRange(m_fixed, "Naval SAM", "SAM_SHIP")
  else
    addRange(m_fixed, "Pop-up SAM", "POPUP")
    addRange(m_fixed, "Radar Emitter", "SAM_CIRCLE")
  end

  -- 2e. SAM Sites
  if not isOverWater then
    local m_sam_sites = MENU_GROUP:New(rec.Group, "SAM Site", ground)
    local sam_config = TCS.Config.A2G.SAMS or {}
    local sorted_sams = {}
    for k, v in pairs(sam_config) do table.insert(sorted_sams, {key=k, label=v.label}) end
    table.sort(sorted_sams, function(a,b)
      local numA = tonumber(string.match(a.key, "SA%-(%d+)"))
      local numB = tonumber(string.match(b.key, "SA%-(%d+)"))
      if numA and numB then
        return numA < numB
      elseif numA then
        return true
      elseif numB then
        return false
      else
        return a.label < b.label
      end
    end)
    for _, sam in ipairs(sorted_sams) do
      addRange(m_sam_sites, sam.label, "SAM_SITE:" .. sam.key)
    end
  end

  -- 2f. Mixed
  local mixed = MENU_GROUP:New(rec.Group, "Mixed", ground)
  if not isOverWater then
    addRange(mixed, "476 Tactical", "range_476_tactical")
    addRange(mixed, "Random Scatter", "random_scatter")
  end

  -- == UTILITY ==
  MENU_GROUP_COMMAND:New(rec.Group, "Reset Range", ground, function()
    if TCS.API and TCS.API.ResetRange then
      TCS.API.ResetRange({ group = rec.Group })
    end
  end)
end
