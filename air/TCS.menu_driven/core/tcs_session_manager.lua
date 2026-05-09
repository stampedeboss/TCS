---------------------------------------------------------------------
-- TCS SESSION MANAGER
--
-- Purpose:
--   Manages player sessions, ownership, and resource registration.
--   Acts as the central state for "who is playing with whom".
---------------------------------------------------------------------
env.info("TCS(SESSION_MANAGER): loading")

TCS = TCS or {}
TCS.SessionManager = {}

-- Internal State
local Sessions = {} -- Key: SessionName (usually Leader Group Name)
local GroupToSession = {} -- Key: GroupName, Value: SessionName

---------------------------------------------------------------------
-- Resource Registry (A2A / A2G Cleanup)
---------------------------------------------------------------------
-- Shared logic for tracking spawned objects per session
local function CreateRegistry()
  local reg = {
    bySession = {} -- Key: SessionName, Value: List of MOOSE Groups/Objects
  }

  function reg:Register(session, object)
    if not session or not object then return end
    local sName = session.Name
    self.bySession[sName] = self.bySession[sName] or {}
    table.insert(self.bySession[sName], object)
  end

  function reg:Cleanup(session)
    if not session then return end
    local sName = session.Name
    local objects = self.bySession[sName] or {}
    for _, obj in ipairs(objects) do
      if obj and obj.Destroy then
        pcall(function() obj:Destroy() end)
      elseif obj and obj.destroy then
        pcall(function() obj:destroy() end)
      end
    end
    self.bySession[sName] = {}
  end

  function reg:CleanupByTag(session, tag)
    -- If objects support tags, filter here. 
    -- For now, this is a full cleanup wrapper or needs specific implementation.
    -- In this basic version, we just cleanup everything for the session 
    -- if the module requests a cleanup, or we could implement tagging later.
    -- For safety in this iteration:
    self:Cleanup(session) 
  end

  return reg
end

TCS.A2G = TCS.A2G or {}
TCS.A2G.Registry = CreateRegistry()

function TCS.SessionManager:CleanupA2ASpawns(session)
  if not session or not session.Name then return 0 end
  
  -- 3-Level Hierarchy Cleanup: TCS_<SessionName>_*
  local prefix = string.format("TCS_%s_", session.Name)
  local groupsToClean = SET_GROUP:New()
    :FilterPrefix(prefix)
    :FilterCategory("AIRPLANE")
    :FilterOnce()
  
  local count = 0
  groupsToClean:ForEach(function(g)
    if g and g:IsAlive() then
      g:Destroy()
      count = count + 1
    end
  end)
  
  env.info(string.format("TCS(SESSION_MANAGER): Cleaned up %d A2A groups for session '%s'", count, session.Name))
  return count
end

---------------------------------------------------------------------
-- Session Logic
---------------------------------------------------------------------

function TCS.SessionManager:GetSessionForGroup(group)
  if not group then return nil end
  local gName = group:GetName()
  local sName = GroupToSession[gName]
  if sName then return Sessions[sName] end
  return nil
end

function TCS.SessionManager:GetOrCreateSessionForGroup(group)
  local existing = self:GetSessionForGroup(group)
  if existing then return existing end

  -- Create new session
  local gName = group:GetName()
  local pName = group:GetPlayerName() or "AI"
  
  local session = {
    Name = gName,
    Owner = gName,
    OwnerUnit = group:GetUnit(1),
    Coalition = group:GetCoalition(),
    Members = { [gName] = group },
    StartTime = timer.getTime()
  }

  -- Methods
  function session:Broadcast(msg, duration)
    for _, memberGroup in pairs(self.Members) do
      if memberGroup and memberGroup:IsAlive() then
        MESSAGE:New(msg, duration):ToGroup(memberGroup)
      end
    end
  end

  Sessions[gName] = session
  GroupToSession[gName] = gName
  
  env.info("TCS(SESSION): Created new session '" .. gName .. "' for player " .. pName)
  return session
end

function TCS.SessionManager:Join(group, sessionName)
  local session = Sessions[sessionName]
  if not session then return false end
  
  local gName = group:GetName()
  
  -- Leave current if any
  self:Leave(group)

  session.Members[gName] = group
  GroupToSession[gName] = sessionName
  
  session:Broadcast(gName .. " has joined the session.", 10)
  return true
end

function TCS.SessionManager:Leave(group)
  if not group then return end
  local gName = group:GetName()
  local sName = GroupToSession[gName]
  
  if sName then
    local session = Sessions[sName]
    if session then
      session.Members[gName] = nil
      -- If owner leaves, maybe migrate or destroy? 
      -- For now, if owner leaves, we cleanup resources.
      if session.Owner == gName then
        self:CleanupA2ASpawns(session)
        TCS.A2G.Registry:Cleanup(session)
        Sessions[sName] = nil -- Destroy session
        env.info("TCS(SESSION): Session '" .. sName .. "' closed (Owner left).")
      end
    end
    GroupToSession[gName] = nil
  end
end

env.info("TCS(SESSION_MANAGER): ready")