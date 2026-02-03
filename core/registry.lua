
env.info("TCS(REGISTRY): loading")

TCS = TCS or {}
-- Unified Registry for all domains (A2A, A2G, etc.)
TCS.Registry = {
  bySession = {} -- [sessionName] = { objects... }
}

-- Backwards compatibility aliases
TCS.A2G = TCS.A2G or {}
TCS.A2G.Registry = TCS.Registry

TCS.A2A = TCS.A2A or {}
TCS.A2A.Registry = TCS.Registry

function TCS.Registry:Register(session, object, tag)
  if not session or not object then return end
  local id = session:GetName()
  self.bySession[id] = self.bySession[id] or {}
  table.insert(self.bySession[id], object)
  
  -- Tagging support for granular cleanup (optional)
  if tag then
    object.TCS_Tag = tag
  end
end

function TCS.Registry:Cleanup(session)
  if not session then return end
  local id = session:GetName()
  local list = self.bySession[id]
  if not list then return end

  for _, obj in ipairs(list) do
    if obj and obj:IsAlive() then
      obj:Destroy()
    end
  end

  self.bySession[id] = nil
end

function TCS.Registry:CleanupByTag(session, tag)
  if not session or not tag then return end
  local id = session:GetName()
  local list = self.bySession[id]
  if not list then return end

  local remaining = {}
  for _, obj in ipairs(list) do
    if obj.TCS_Tag == tag then
      if obj and obj:IsAlive() then obj:Destroy() end
    else
      table.insert(remaining, obj)
    end
  end
  self.bySession[id] = remaining
end

function TCS.Registry:CleanupGroup(session, groupName)
  -- Placeholder: If we need per-group cleanup later
end

env.info("TCS(REGISTRY): ready")
