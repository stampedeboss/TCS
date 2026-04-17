
env.info("TCS(REGISTRY): loading")

TCS = TCS or {}
-- Unified Registry for all domains (A2A, A2G, etc.)
TCS.Registry = {
  byZone = {} -- [zoneId] = { objects... }
}

-- Backwards compatibility aliases
TCS.A2G = TCS.A2G or {}
TCS.A2G.Registry = TCS.Registry

TCS.A2A = TCS.A2A or {}
TCS.A2A.Registry = TCS.Registry

function TCS.Registry:Register(zoneId, object, tag)
  if not zoneId or not object then return end
  self.byZone[zoneId] = self.byZone[zoneId] or {}
  table.insert(self.byZone[zoneId], object)
  
  -- Tagging support for granular cleanup (optional)
  if tag then
    object.TCS_Tag = tag
  end
end

function TCS.Registry:Cleanup(zoneId)
  if not zoneId then return end
  local list = self.byZone[zoneId]
  if not list then return end

  for _, obj in ipairs(list) do
    if obj and obj.IsAlive and obj:IsAlive() then
      -- Pre-emptive fix for MOOSE bug where waypoints can be nil on destroy
      if obj.ClassName == "GROUP" and not obj.waypoints then
        obj.waypoints = {}
      end
      pcall(function() obj:Destroy() end)
    end
  end

  self.byZone[zoneId] = nil
end

function TCS.Registry:CleanupByTag(zoneId, tag)
  if not zoneId or not tag then return end
  local list = self.byZone[zoneId]
  if not list then return end

  local remaining = {}
  for _, obj in ipairs(list) do
    if obj.TCS_Tag == tag then
      if obj and obj:IsAlive() then obj:Destroy() end
    else
      table.insert(remaining, obj)
    end
  end
  self.byZone[zoneId] = remaining
end

function TCS.Registry:CleanupGroup(zoneId, groupName)
  -- Placeholder: If we need per-group cleanup later
end

env.info("TCS(REGISTRY): ready")
