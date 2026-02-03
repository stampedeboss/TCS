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
-- TCS.Session Class
---------------------------------------------------------------------
TCS.Session = {}
TCS.Session.__index = TCS.Session

function TCS.Session:New(name, leadGroupName)
  local o = {
    Name = name,
    LeadGroupName = leadGroupName,
    Members = {},     -- [groupName] = true
    ActiveModes = {}, -- [key] = modeObj (A2A)
  }
  setmetatable(o, TCS.Session)
  if leadGroupName then o.Members[leadGroupName] = true end
  return o
end

function TCS.Session:GetName() return self.Name end

function TCS.Session:IsLead(groupName)
  return self.LeadGroupName == groupName
end

function TCS.Session:AddMember(groupName)
  self.Members[groupName] = true
  if not self.LeadGroupName then self.LeadGroupName = groupName end
end

function TCS.Session:RemoveMember(groupName)
  self.Members[groupName] = nil
  if self.LeadGroupName == groupName then
    self.LeadGroupName = nil
    -- Promote next available member
    for m in pairs(self.Members) do
      self.LeadGroupName = m
      local g = GROUP:FindByName(m)
      if g then MsgToGroup(g, "You are now Session " .. self.Name .. " LEAD.", 10) end
      break
    end
  end
end

function TCS.Session:IsEmpty()
  return next(self.Members) == nil
end

function TCS.Session:Broadcast(text, seconds)
  for m in pairs(self.Members) do
    local g = GROUP:FindByName(m)
    if g then MsgToGroup(g, text, seconds) end
  end
end

function TCS.Session:ForEachMemberRec(fn)
  for m in pairs(self.Members) do
    local g = GROUP:FindByName(m)
    if g then
      -- Try global GetPlayer (A2A)
      local rec = nil
      if GetPlayer then rec = GetPlayer(g) end
      if rec then fn(rec) end
    end
  end
end

function TCS.Session:TerminateModes(reason)
  for _, m in pairs(self.ActiveModes) do
    if m and m.Terminate then pcall(function() m:Terminate(reason) end) end
  end
  self.ActiveModes = {}
end

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
  -- Unified Registry Cleanup
  if TCS.Registry then
    if groupName then
      TCS.Registry:CleanupGroup(session, groupName)
    else
      TCS.Registry:Cleanup(session)
    end
  end

  -- SUW / MAR / future domains plug in here
end

---------------------------------------------------------------------
-- SESSION LIFECYCLE
---------------------------------------------------------------------

TCS.SessionManager.Sessions = {}       -- Name -> Session
TCS.SessionManager.GroupToSession = {} -- GroupName -> Session

function TCS.SessionManager:CreateSession(name, leadGroup)
  local gname = _getGroupName(leadGroup)
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
  local groupName = _getGroupName(group)
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

  local gname = _getGroupName(group)
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
  local groupName = _getGroupName(group)
  if not groupName then return nil end

  local session = self.GroupToSession[groupName]
  if session then
    return session
  end

  local name = (opts and opts.name) or ("SESSION_" .. groupName)
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
  local groupName = _getGroupName(group)
  return groupName and self.GroupToSession[groupName] or nil
end

function TCS.SessionManager:GetSession(name)
  return self.Sessions[name]
end

function TCS.SessionManager:GetAllSessions()
  return self.Sessions
end

env.info("TCS(SESSION.MANAGER): ready")
