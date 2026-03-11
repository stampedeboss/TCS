---------------------------------------------------------------------
-- core/session_manager.lua
--
-- TCS Session Manager
--
-- Responsibilities:
--   • Enforce one-session-per-pilot invariant
--   • Handle session creation, join, leave, destroy
--   • Coordinate cleanup across ALL domains
--   • Provide atomic session transitions
--
-- Design Principles:
--   • Sessions own world state
--   • Pilots lease sessions
--   • Domains never manage sessions directly
---------------------------------------------------------------------

env.info("TCS(SESSION.MANAGER): loading")

TCS = TCS or {}
TCS.SessionManager = {}
TCS.SessionManager.__index = TCS.SessionManager

---------------------------------------------------------------------
-- Internal Utilities
---------------------------------------------------------------------

local function _log(msg)
  env.info("TCS(SESSION): " .. msg)
end

---------------------------------------------------------------------
-- DOMAIN CLEANUP DISPATCH
---------------------------------------------------------------------

local function _cleanupDomainArtifacts(session, groupName)
  -- Unified Registry Cleanup
  if TCS.Registry then
    if groupName then
      TCS.Registry:CleanupGroup(session, groupName)
    else
      TCS.Registry:Cleanup(session)
    end
  end

  -- Explicitly clean A2A/A2G registries if they differ or exist separately
  if TCS.A2A and TCS.A2A.Registry and TCS.A2A.Registry ~= TCS.Registry then
     if TCS.A2A.Registry.Cleanup then TCS.A2A.Registry:Cleanup(session) end
  end

  -- SUW / MAR / future domains plug in here
end

-- Public interface for terminating active scenarios and cleaning up artifacts
function TCS.SessionManager:TerminateSessionScenarios(session)
  if not session then return end
  _log("terminating all scenarios for session " .. session:GetName())
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
      TCS.RANGE.Reset(memberName)
    end
  end

  self:CleanupA2ASpawns(session)
  self:CleanupA2GSpawns(session)
  _cleanupDomainArtifacts(session, nil)
end

---------------------------------------------------------------------
-- SESSION LIFECYCLE
---------------------------------------------------------------------

TCS.SessionManager.Sessions = {}       -- Name -> Session
TCS.SessionManager.GroupToSession = {} -- GroupName -> Session

function TCS.SessionManager:CreateSession(name, leadGroup)
  local gname = TCS.SessionUtils.GetGroupName(leadGroup)
  if not gname then return nil end

  -- If group already in session, leave it
  self:LeaveSession(leadGroup)

  local s = TCS.Session:New(name, gname)
  self.Sessions[name] = s
  self.GroupToSession[gname] = s
  _log("created session " .. name .. " owned by " .. gname)

  return s
end

function TCS.SessionManager:DestroySession(session)
  if not session then return end

  local name = session:GetName()
  _log("destroying session " .. name)

  -- Full cleanup across all domains
  session:TerminateModes("DESTROY")
  self:CleanupA2ASpawns(session)
  self:CleanupA2GSpawns(session)
  _cleanupDomainArtifacts(session, nil)

  -- Remove all group bindings
  for groupName, s in pairs(self.GroupToSession) do
    if s == session then
      self.GroupToSession[groupName] = nil
    end
  end

  self.Sessions[name] = nil
end

---------------------------------------------------------------------
-- GROUP TRANSITIONS
---------------------------------------------------------------------

function TCS.SessionManager:LeaveSession(group)
  local groupName = TCS.SessionUtils.GetGroupName(group)
  if not groupName then return end

  local session = self.GroupToSession[groupName]
  if not session then return end

  _log(groupName .. " leaving session " .. session:GetName())

  MsgToGroup(group, "Left Session " .. session.Name .. ".", 6)
  _cleanupDomainArtifacts(session, groupName)
  session:RemoveMember(groupName)
  self.GroupToSession[groupName] = nil

  if session:IsEmpty() then
    self:DestroySession(session)
  end
end

function TCS.SessionManager:JoinSession(sessionName, group)
  local s = self.Sessions[sessionName]
  if not s then
    return self:CreateSession(sessionName, group)
  end

  local gname = TCS.SessionUtils.GetGroupName(group)
  if self.GroupToSession[gname] == s then return s end

  self:LeaveSession(group)
  s:AddMember(gname)
  self.GroupToSession[gname] = s
  MsgToGroup(group, "Joined Session " .. sessionName .. ". Lead: " .. tostring(s.LeadGroupName), 10)
  return s
end

---------------------------------------------------------------------
-- GET OR CREATE (IMPLICIT SESSION)
---------------------------------------------------------------------

function TCS.SessionManager:GetOrCreateSessionForGroup(group, opts)
  local groupName = TCS.SessionUtils.GetGroupName(group)
  if not groupName then return nil end

  local session = self.GroupToSession[groupName]
  if session then
    return session
  end

  local name = (opts and opts.name)
  if not name then
     local pName = group:GetPlayerName()
     if pName then
        local callsign = TCS.SessionUtils.ParseCallsign(pName)
        if callsign then
           -- Ensure uniqueness
           local baseName = callsign
           local count = 1
           while self.Sessions[callsign] do
             count = count + 1
             callsign = baseName .. " " .. count
           end
           name = callsign
        end
     end
  end
  
  name = name or ("SESSION_" .. groupName)
  return self:CreateSession(name, group)
end

-- Helper for A2A legacy compatibility
function TCS.SessionManager:Ensure(name)
  -- Creates a session without a specific owner initially if called without group
  local s = self.Sessions[name]
  if not s then
    s = TCS.Session:New(name, nil)
    self.Sessions[name] = s
  end
  return s
end

---------------------------------------------------------------------
-- QUERY HELPERS
---------------------------------------------------------------------

function TCS.SessionManager:GetSessionForGroup(group)
  local groupName = TCS.SessionUtils.GetGroupName(group)
  return groupName and self.GroupToSession[groupName] or nil
end

function TCS.SessionManager:GetSession(name)
  return self.Sessions[name]
end

function TCS.SessionManager:GetAllSessions()
  return self.Sessions
end

---------------------------------------------------------------------
-- SESSION MONITOR (Auto-Cleanup)
---------------------------------------------------------------------
local SessionMonitor = {}
function SessionMonitor:onEvent(event)
  if not event or not event.initiator then return end
  
  local id = event.id
  if id == world.event.S_EVENT_DEAD or 
     id == world.event.S_EVENT_CRASH or 
     id == world.event.S_EVENT_EJECTION or 
     id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
     
     local unit = event.initiator
     if not unit.getGroup then return end
     local group = unit:getGroup()
     if not group then return end
     
     local session = TCS.SessionManager:GetSessionForGroup(group)
     if session then
        timer.scheduleFunction(function()
           -- Check if session still exists in manager
           if not TCS.SessionManager.Sessions[session.Name] then return end
           
           local hasActivePlayers = false
           for gName, _ in pairs(session.Members) do
              local g = Group.getByName(gName)
              if g and g:isExist() then
                 for _, u in ipairs(g:getUnits()) do
                    if u:isExist() and u:getLife() > 0 and u:getPlayerName() then
                       hasActivePlayers = true
                       break
                    end
                 end
              end
              if hasActivePlayers then break end
           end
           
           if not hasActivePlayers then
              env.info("TCS(SESSION): Auto-closing session " .. session.Name .. " (No active players).")
              TCS.SessionManager:DestroySession(session)
           end
        end, nil, timer.getTime() + 10)
     end
  end
end
world.addEventHandler(SessionMonitor)

env.info("TCS(SESSION.MANAGER): ready")
