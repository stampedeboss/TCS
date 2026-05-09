---------------------------------------------------------------------
-- TCS SIGNALS: CONFIG
-- Configuration for Communications & External Integrations.
---------------------------------------------------------------------
env.info("TCS(SIGNALS.CONFIG): loading")

TCS = TCS or {}
TCS.Signals = TCS.Signals or {}
TCS.Signals.Config = TCS.Signals.Config or {}

TCS.Signals.Config.AWACS = {
  Label = "DARKSTAR", 
  Freq = 251.200, 
  Mod = radio.modulation.AM,
  SRSPath = [[C:\ProgramData\DCS-SimpleRadio-Standalone]],
  Port = 5002, -- Default, resolved below
  Gender = "female", 
  Culture = "en-US",
  UpdateTotal = 180, 
  UpdateEvery = 30,
}

-- Resolve SRS Port dynamically based on server instance
if lfs then
  local path = lfs.writedir()
  if string.find(path, 'FlyingWrecksAlpha') then TCS.Signals.Config.AWACS.Port = 5002
  elseif string.find(path, 'FlyingWrecksBravo') then TCS.Signals.Config.AWACS.Port = 5003
  elseif string.find(path, 'FlyingWrecksCharlie') then TCS.Signals.Config.AWACS.Port = 5004
  elseif string.find(path, 'StampedesPlayground') then TCS.Signals.Config.AWACS.Port = 5005
  else
    TCS.Signals.Config.AWACS.Port = 5002
    TCS.Signals.Config.AWACS.SRSPath = [[C:\Program Files\DCS-SimpleRadio-Standalone]]
  end
end

env.info("TCS(SIGNALS.CONFIG): ready")