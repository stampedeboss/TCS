---------------------------------------------------------------------
-- TCS SESSION CLASS
-- Defines the Session object structure and methods.
---------------------------------------------------------------------
env.info("TCS(SESSION.CLASS): loading")

TCS = TCS or {}
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
      if g then TCS.MsgToGroup(g, "You are now Session " .. self.Name .. " LEAD.", 10) end
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
    if g then TCS.MsgToGroup(g, text, seconds) end
  end
end

function TCS.Session:ForEachMemberRec(fn)
  for m in pairs(self.Members) do
    local g = GROUP:FindByName(m)
    if g then
      -- Resolve Player Record
      local rec = nil
      if PLAYERS and PLAYERS.GetByGroup then rec = PLAYERS:GetByGroup(g) end
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

env.info("TCS(SESSION.CLASS): ready")