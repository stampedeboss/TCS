env.info("TCS(SESSION.CLEANUP): loading")

TCS = TCS or {}
TCS.SessionManager = TCS.SessionManager or {}

local function _cleanupDomainArtifacts(session, groupName)
  -- Unified Registry Cleanup
  if TCS.Registry then
    if groupName then
      TCS.Registry:CleanupGroup(session, groupName)
    else
      TCS.Registry:Cleanup(session)
    end
  end
end

function TCS.SessionManager:CleanupA2ASpawns(session)
  if not session or not session.Name then return 0 end
  local prefix = string.format("TCS_%s_", session.Name)
  local count = 0
  env.info(string.format("TCS(CLEANUP): Checking for A2A prefix '%s'", prefix))

  local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
  for _, side in ipairs(sides) do
    local groups = coalition.getGroups(side, Group.Category.AIRPLANE) or {}
    for _, g in ipairs(groups) do
      if g and g:isExist() then
        local gName = g:getName()
        if string.sub(gName, 1, #prefix) == prefix then
          env.info(string.format("TCS(CLEANUP): A2A Match found! Destroying '%s'", gName))
          g:destroy()
          count = count + 1
        end
      end
    end
  end

  env.info(string.format("TCS(SESSION_MANAGER): Cleaned up %d A2A groups for session '%s'", count, session.Name))
  return count
end

function TCS.SessionManager:CleanupA2GSpawns(session)
  if not session or not session.Name then return 0 end
  local prefix = string.format("TCS_%s_", session.Name)
  local count = 0
  env.info(string.format("TCS(CLEANUP): Checking for A2G prefix '%s'", prefix))
  
  local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
  local cats = { Group.Category.GROUND, Group.Category.SHIP, Group.Category.TRAIN }
  
  for _, side in ipairs(sides) do
    for _, cat in ipairs(cats) do
      local groups = coalition.getGroups(side, cat) or {}
      for _, g in ipairs(groups) do
        if g and g:isExist() then
          local gName = g:getName()
          if string.sub(gName, 1, #prefix) == prefix then
            env.info(string.format("TCS(CLEANUP): A2G Match found! Destroying '%s'", gName))
            g:destroy()
            count = count + 1
          end
        end
      end
    end
  end

  -- Statics cleanup via coalition.getStaticObjects
  for _, side in ipairs(sides) do
    local statics = coalition.getStaticObjects(side) or {}
    for _, s in ipairs(statics) do
      if s and s:isExist() then
        local sName = s:getName()
        if string.sub(sName, 1, #prefix) == prefix then
          env.info(string.format("TCS(CLEANUP): A2G Static Match found! Destroying '%s'", sName))
          s:destroy()
          count = count + 1
        end
      end
    end
  end
  
  env.info(string.format("TCS(SESSION_MANAGER): Cleaned up %d A2G objects for session '%s'", count, session.Name))
  return count
end

-- Public interface for terminating active scenarios and cleaning up artifacts
function TCS.SessionManager:TerminateSessionScenarios(session)
  if not session then return end
  env.info("TCS(SESSION): terminating all scenarios for session " .. session:GetName())
  session:TerminateModes("USER_TERMINATE")

  -- Explicitly stop all tracked scenarios (cleans up drawings/markers and flags)
  if session.ActiveScenarios and TCS.Scenario and TCS.Scenario.Stop then
    local tags = {}
    for tag, _ in pairs(session.ActiveScenarios) do table.insert(tags, tag) end
    for _, tag in ipairs(tags) do
      TCS.Scenario.Stop(session, tag)
    end
  end

  -- Clean up Ranges owned by session members
  if TCS.RANGE and TCS.RANGE.Reset then
    for memberName, _ in pairs(session.Members) do
      pcall(TCS.RANGE.Reset, memberName)
    end
  end

  self:CleanupA2ASpawns(session)
  self:CleanupA2GSpawns(session)
  _cleanupDomainArtifacts(session, nil)
end

env.info("TCS(SESSION.CLEANUP): ready")