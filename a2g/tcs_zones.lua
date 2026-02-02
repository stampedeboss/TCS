function SUW:InitZones()
  self.Zones = {}
  for k, name in pairs(self.Config.PatrolZones) do
    self.Zones[k] = ZONE:New(name)
    self.State.PatrolStatus[k] = "UNKNOWN"
  end
end
