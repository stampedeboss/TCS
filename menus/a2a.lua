---------------------------------------------------------------------
-- menus/a2a.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2A")

function TCS.Menu.BuildA2A(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Intercept", root.A2A, function()
    if DeployIntercept then DeployIntercept({ group = rec.Group, forceSize = "SQUADRON" }) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAP", root.A2A, function()
    if DeployAirPatrol then DeployAirPatrol({ group = rec.Group, forceSize = "SQUADRON" }) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Sweep", root.A2A, function()
    if DeployAirSweep then DeployAirSweep({ group = rec.Group, forceSize = "SQUADRON" }) end
  end)

  local escort = MENU_GROUP:New(rec.Group, "Escort", root.A2A)

  local function startEscort(pkgName)
    if DeployEscort then DeployEscort({ group = rec.Group, package = pkgName, forceSize = "SQUADRON" }) end
  end

  MENU_GROUP_COMMAND:New(rec.Group, "Random", escort, function()
    local pkgs = {
      "STRIKE", "STRIKE_F18", "STRIKE_A10",
      "AWACS_E3", "AWACS_E2", "TANKER", "TANKER_S3",
      "BOMBER", "BOMBER_B1", "TRANSPORT", "TRANSPORT_C17"
    }
    startEscort(pkgs[math.random(#pkgs)])
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Strike (F-15E)", escort, function() startEscort("STRIKE") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Strike (F/A-18C)", escort, function() startEscort("STRIKE_F18") end)
  MENU_GROUP_COMMAND:New(rec.Group, "CAS (A-10C)", escort, function() startEscort("STRIKE_A10") end)
  
  local hv = MENU_GROUP:New(rec.Group, "HVAA", escort)
  MENU_GROUP_COMMAND:New(rec.Group, "AWACS (E-3A)", hv, function() startEscort("AWACS_E3") end)
  MENU_GROUP_COMMAND:New(rec.Group, "AWACS (E-2C)", hv, function() startEscort("AWACS_E2") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Tanker (KC-135)", hv, function() startEscort("TANKER") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Tanker (S-3B)", hv, function() startEscort("TANKER_S3") end)

  local hvy = MENU_GROUP:New(rec.Group, "Heavy", escort)
  MENU_GROUP_COMMAND:New(rec.Group, "Bomber (B-52H)", hvy, function() startEscort("BOMBER") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Bomber (B-1B)", hvy, function() startEscort("BOMBER_B1") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Cargo (C-130)", hvy, function() startEscort("TRANSPORT") end)
  MENU_GROUP_COMMAND:New(rec.Group, "Cargo (C-17A)", hvy, function() startEscort("TRANSPORT_C17") end)

  MENU_GROUP_COMMAND:New(rec.Group, "BVR Random", root.A2A, function()
    if DeployIntercept then
      DeployIntercept({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "ACM H2H", root.A2A, function()
    if TCS.API and TCS.API.CreateA2ATraining_H2H then
      TCS.API.CreateA2ATraining_H2H({ group = rec.Group, mode = "GUNS" })
    end
  end)
end
