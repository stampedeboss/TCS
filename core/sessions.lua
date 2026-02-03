-- TCS_session.lua (Human Sessions)
-- Purpose: allow multiple separate CLIENT groups (e.g., Airboss-style) to cooperate in one TCS session.
-- A session has:
--   * Name (ALPHA/BRAVO/CHARLIE)
--   * Lead group (controls scenario start)
--   * Member groups (receive shared calls/updates)
-- Scenarios spawned by the session are shared; only one set of bandits is created.

-- ADAPTER: Delegates to TCS.SessionManager

TCS = TCS or {}
TCS.Sessions = {}

function TCS.Sessions:Ensure(name)
  return TCS.SessionManager:Ensure(name)
end

function TCS.Sessions:CountActive()
  local n = 0
  for _ in pairs(TCS.SessionManager.Sessions) do n = n + 1 end
  return n
end

function TCS.Sessions:GetOnlyActiveName()
  local only = nil
  for k in pairs(TCS.SessionManager.Sessions) do
    if only then return nil end
    only = k
  end
  return only
end

function TCS.Sessions:GetForRec(rec)
  if not rec or not rec.Group then return nil end
  return TCS.SessionManager:GetSessionForGroup(rec.Group)
end

function TCS.Sessions:IsLead(rec)
  local s = self:GetForRec(rec)
  if not s or not rec.Group then return false end
  return s:IsLead(rec.Group:GetName())
end

function TCS.Sessions:SetLead(sessionName, rec)
  if not rec or not rec.Group then return end
  TCS.SessionManager:CreateSession(sessionName, rec.Group)
  MsgToGroup(rec.Group, "Session " .. sessionName .. " created. You are LEAD.", 10)
end

function TCS.Sessions:Join(sessionName, rec)
  if not rec or not rec.Group then return end
  TCS.SessionManager:JoinSession(sessionName, rec.Group)
end

function TCS.Sessions:Leave(rec)
  if not rec or not rec.Group then return end
  TCS.SessionManager:LeaveSession(rec.Group)
end

function TCS.Sessions:Broadcast(sessionName, text, seconds)
  local s = TCS.SessionManager:GetSession(sessionName)
  if s then s:Broadcast(text, seconds) end
end

function TCS.Sessions:ForEachMemberRec(sessionName, fn)
  local s = TCS.SessionManager:GetSession(sessionName)
  if s then s:ForEachMemberRec(fn) end
end
