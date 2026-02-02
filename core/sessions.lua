-- TCS_session.lua (Human Sessions)
-- Purpose: allow multiple separate CLIENT groups (e.g., Airboss-style) to cooperate in one TCS session.
-- A session has:
--   * Name (ALPHA/BRAVO/CHARLIE)
--   * Lead group (controls scenario start)
--   * Member groups (receive shared calls/updates)
-- Scenarios spawned by the session are shared; only one set of bandits is created.

SESSION = {
  Active = {}, -- Active[name] = { Name, LeadGroupName, Members = { [groupName]=true }, ActiveModes = {CAP=mode,...} }
}

local function _msgGroupByName(gname, text, seconds)
  if not gname then return end
  local g = GROUP:FindByName(gname)
  if g then MsgToGroup(g, text, seconds) end
end

function SESSION:Ensure(name)
  if not name then return nil end
  local s = self.Active[name]
  if not s then
    s = { Name = name, LeadGroupName = nil, Members = {}, ActiveModes = {} }
    self.Active[name] = s
  end
  return s
end

function SESSION:CountActive()
  local n = 0
  for _ in pairs(self.Active) do n = n + 1 end
  return n
end

function SESSION:GetOnlyActiveName()
  local only = nil
  for k in pairs(self.Active) do
    if only then return nil end
    only = k
  end
  return only
end

function SESSION:GetForRec(rec)
  if not rec or not rec.Session then return nil end
  return self.Active[rec.Session]
end

function SESSION:IsLead(rec)
  local s = self:GetForRec(rec)
  if not s or not s.LeadGroupName or not rec or not rec.Group then return false end
  return rec.Group:GetName() == s.LeadGroupName
end

function SESSION:SetLead(sessionName, rec)
  if not rec or not rec.Group then return end
  local s = self:Ensure(sessionName)
  local gname = rec.Group:GetName()
  s.LeadGroupName = gname
  s.Members[gname] = true
  rec.Session = sessionName
  MsgToGroup(rec.Group, "Session " .. sessionName .. " created. You are LEAD.", 10)
end

function SESSION:Join(sessionName, rec)
  if not rec or not rec.Group then return end
  local s = self:Ensure(sessionName)
  local gname = rec.Group:GetName()
  s.Members[gname] = true
  if not s.LeadGroupName then s.LeadGroupName = gname end
  rec.Session = sessionName
  MsgToGroup(rec.Group, "Joined Session " .. sessionName .. ". Lead: " .. tostring(s.LeadGroupName), 10)
end

function SESSION:Leave(rec)
  if not rec or not rec.Group then return end
  local s = self:GetForRec(rec)
  if not s then
    MsgToGroup(rec.Group, "Not in a session.", 6)
    return
  end
  local gname = rec.Group:GetName()
  s.Members[gname] = nil
  rec.Session = nil
  MsgToGroup(rec.Group, "Left Session " .. s.Name .. ".", 6)

  -- If lead left, promote any remaining member
  if s.LeadGroupName == gname then
    s.LeadGroupName = nil
    for member in pairs(s.Members) do
      s.LeadGroupName = member
      _msgGroupByName(member, "You are now Session " .. s.Name .. " LEAD.", 10)
      break
    end
  end

  -- If empty, clean up
  local empty = true
  for _ in pairs(s.Members) do empty = false; break end
  if empty then
    -- Terminate session modes
    for _, m in pairs(s.ActiveModes) do
      if m and m.Terminate then pcall(function() m:Terminate("SESSION END") end) end
    end
    SESSION.Active[s.Name] = nil
  end
end

function SESSION:Broadcast(sessionName, text, seconds)
  local s = self.Active[sessionName]
  if not s then return end
  for member in pairs(s.Members) do
    _msgGroupByName(member, text, seconds)
  end
end

function SESSION:ForEachMemberRec(sessionName, fn)
  local s = self.Active[sessionName]
  if not s then return end
  for member in pairs(s.Members) do
    local g = GROUP:FindByName(member)
    if g then
      local rec = GetPlayer(g)
      if rec then fn(rec) end
    end
  end
end
