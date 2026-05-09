---------------------------------------------------------------------
-- menus/admin.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading ADMIN")

function TCS.Menu.BuildAdmin(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Reset All Menus", root.ADMIN, function()
    if PLAYERS and PLAYERS.ByName and TCS.Menu and TCS.Menu.BuildForPlayer then
      for _, p in pairs(PLAYERS.ByName) do
        TCS.Menu.BuildForPlayer(p)
      end
      MESSAGE:New("All menus reset.", 10):ToGroup(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Cleanup My Spawns", root.ADMIN, function()
    if TerminateMyBandits then
      TerminateMyBandits(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Cleanup All Spawns", root.ADMIN, function()
    local prefixes = { "BANDIT", "CAS", "BAI", "SAM", "STRIKE", "MAR", "SUW", "ACM", "DRONE", "CIV_TRAFFIC", "FAC_HIDDEN" }
    local count = 0
    
    local function cleanCat(cat)
      for _, side in pairs({coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL}) do
        local groups = coalition.getGroups(side, cat) or {}
        for _, g in ipairs(groups) do
          local name = g:getName()
          for _, p in ipairs(prefixes) do
            if string.find(name, "^" .. p) then
              g:destroy()
              count = count + 1
              break
            end
          end
        end
      end
    end

    cleanCat(Group.Category.AIRPLANE)
    cleanCat(Group.Category.GROUND)
    cleanCat(Group.Category.SHIP)

    MESSAGE:New("Cleanup complete. Removed " .. count .. " groups.", 10):ToGroup(rec.Group)
  end)

  -- Developer menu is only available to admins
  -- Ensure Group is a valid MOOSE object
  local groupObj = rec.Group
  if groupObj and groupObj.GetPlayerID then
  if TCS.SessionUtils.IsAdmin(groupObj:GetPlayerID()) then
    local m_developer  = MENU_GROUP:New(rec.Group, "DEVELOPER", root.ADMIN)
    MENU_GROUP_COMMAND:New(rec.Group, "Test TTS", m_developer, function()
      if TCS.AWACS and TCS.AWACS.TestTTS then
        local phrase = "Radio check. Testing text to speech."
        local label = (TCS.Config and TCS.Config.AWACS and TCS.Config.AWACS.Label) or "MAGIC"
        local display = string.format("%s. %s", label, phrase)
        MESSAGE:New("TCS TTS TEST: " .. display, 10):ToGroup(rec.Group)
        TCS.AWACS.TestTTS(phrase)
      else
        MESSAGE:New("TTS module not loaded.", 5):ToGroup(rec.Group)
      end
    end)
    MENU_GROUP_COMMAND:New(rec.Group, "Test CAS (Current Loc)", m_developer, function()
      if TCS.A2G and TCS.A2G.CAS and TCS.A2G.CAS.MenuRequest then
        TCS.A2G.CAS.MenuRequest(rec.Group)
      end
    end)
  end
  end

  if TCS.Menu.BuildTasking then TCS.Menu.BuildTasking(rec) end
end