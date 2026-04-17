TCS = TCS or {}
TCS.SUW = TCS.SUW or {}

function TCS.SUW:InitZones()
  self.Zones = {}
  self.State = self.State or {}
  self.State.PatrolStatus = self.State.PatrolStatus or {}

  if self.Config and self.Config.PatrolZones then
    for k, name in pairs(self.Config.PatrolZones) do
      self.Zones[k] = ZONE:New(name)
      self.State.PatrolStatus[k] = "UNKNOWN"
    end
  end
end
