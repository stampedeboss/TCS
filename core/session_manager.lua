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
-- Internal State
---------------------------------------------------------------------

-- groupName -> session
TCS.SessionManager.GroupToSession = {}

-- sessionName -> session
TCS.SessionManager.Sessions = {}

---------------------------------------------------------------------
-- Internal Utilities
---------------------------------------------------------------------

local function _log(msg)
  env.info("TCS(SESSION): " .. msg)
end

local function _getGroupName(group)
  return group and group.GetName and group:GetName() or nil
end

---------------------------------------------------------------------
-- DOMAIN CLEANUP DISPATCH
---------------------------------------------------------------------

local function _cleanupDomainArtifacts(session, groupName)
  -- A2G
  if TCS.A2G and TCS.A2G.Registry then
    if groupName then
      TCS.A2G.Registry:CleanupGroup(session, groupName)
    else
      TCS.A2G.Registry:Cleanup(session)
    end
  end

  -- A2A
  if TCS.A2A and TCS.A2A.Registry then
    if groupName then
      TCS.A2A.Registry:CleanupGroup(session, groupName)
    else
      TCS.A2A.Registry:Cleanup(session)
    end
  end

  -- SUW / MAR / future domains plug in here
end

---------------------------------------------------------------------
-- SESSION LIFECYCLE
---------------------------------------------------------------------

function TCS.SessionManager:CreateSession(ownerGroup, opts)
  local ownerName = _getGroupName(ownerGroup)
  if not ownerName then return nil end

  local name = opts and opts.name or ("SESSION_" .. ownerName)

  local session = TCS.Session:New({
    name  = name,
    owner = ownerName,
    mode  = opts and opts.mode or "OPERATIONAL",
  })

  self.Sessions[name] = session
  _log("created session " .. name .. " owned by " .. ownerName)

  return session
end

function TCS.SessionManager:DestroySession(session)
  if not session then return end

  local name = session:GetName()
  _log("destroying session " .. name)

  -- Full cleanup across all domains
  _cleanupDomainArtifacts(session, nil)

  -- Remove all group bindings
  for groupName, s in pairs(self.GroupToSession) do
    if s == session then
      self.GroupToSession[groupName] = nil
    end
  end

  self.Sessions[name] = nil
  session:Destroy()
end

---------------------------------------------------------------------
-- GROUP TRANSITIONS
---------------------------------------------------------------------

function TCS.SessionManager:LeaveSession(group)
  local groupName = _getGroupName(group)
  if not groupName then return end

  local session = self.GroupToSession[groupName]
  if not session then return end

  _log(groupName .. " leaving session " .. session:GetName())

  if session:IsOwner(groupName) then
    -- Owner leaving destroys the session
    self:DestroySession(session)
  else
    -- Member leaving: clean only their artifacts
    _cleanupDomainArtifacts(session, groupName)
    session:RemoveMember(groupName)
  end

  self.GroupToSession[groupName] = nil
end

function TCS.SessionManager:JoinSession(group, targetSession)
  local groupName = _getGroupName(group)
  if not groupName or not targetSession then return end

  -- Atomic transition
  self:LeaveSession(group)

  targetSession:AddMember(groupName)
  self.GroupToSession[groupName] = targetSession

  _log(groupName .. " joined session " .. targetSession:GetName())
end

---------------------------------------------------------------------
-- GET OR CREATE (IMPLICIT SESSION)
---------------------------------------------------------------------

function TCS.SessionManager:GetOrCreateSessionForGroup(group, opts)
  local groupName = _getGroupName(group)
  if not groupName then return nil end

  local session = self.GroupToSession[groupName]
  if session then
    return session
  end

  session = self:CreateSession(group, opts)
  session:AddMember(groupName)
  self.GroupToSession[groupName] = session

  return session
end

---------------------------------------------------------------------
-- QUERY HELPERS
---------------------------------------------------------------------

function TCS.SessionManager:GetSessionForGroup(group)
  local groupName = _getGroupName(group)
  return groupName and self.GroupToSession[groupName] or nil
end

function TCS.SessionManager:GetAllSessions()
  return self.Sessions
end

env.info("TCS(SESSION.MANAGER): ready")
