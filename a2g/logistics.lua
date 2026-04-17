---------------------------------------------------------------------
-- TCS A2G LOGISTICS
--
-- Purpose:
--   Supply convoys and restoration of capabilities.
--   Spawns a convoy that travels from a rear area to the front.
---------------------------------------------------------------------
env.info("TCS(A2G.LOGISTICS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.LOGISTICS = {}

local TAG = "LOGISTICS"

function TCS.A2G.LOGISTICS:Start(rec, destination, echelon)
  if not rec then return end
  local group = rec.Group
  local session = rec.Session or TCS.SessionManager:GetOrCreateSessionForGroup(group)

  -- 1. Standard Scenario Setup
  -- Bias=false because logistics usually targets a specific friendly asset/base
  destination = TCS.Scenario.Setup(session, TAG, destination, group, {Bias=false, domain="A2G"})
  if not destination then return end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  -- Calculate Source (Rear area)
  -- Source is 15-20 NM "behind" the destination relative to group heading
  local hdg = 0
  local unit = rec.Unit or (group and group:GetUnit(1))
  if unit then hdg = unit:GetHeading() end
  
  local dist = math.random(15, 20) * 1852
  local source = destination:Translate(dist, (hdg + 180) % 360)

  -- Visual Mark (Friendly Start)
  if group then
    trigger.action.smoke(source:GetVec3(), trigger.smokeColor.Blue)
  end

  -- Spawn Force
  local force = TCS.A2G.ForceSpawner.Spawn(session, TAG, echelon, source, {coalition=session.Coalition or coalition.side.BLUE})
  
  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, destination, echelon, 5000, {0,0,1,1}, {0,0,1,0.15})

  local taskHandle = {
    ConvoyGroups = force,
    Destination = destination,
    StartTime = timer.getTime(),
    Duration = 7200,
    Status = "ACTIVE"
  }

  if force and #force > 0 then
    -- Route to destination
    local speedKph = 40
    local speedMs = speedKph / 3.6
    
    for _, g in ipairs(force) do
      if g and g.TaskRouteToVec2 then g:TaskRouteToVec2(destination:GetVec2(), speedMs, "On Road") end
    end

    if group then MESSAGE:New("TCS: Supply convoy dispatched from rear area.", 10):ToGroup(group) end
  else
    if group then MESSAGE:New("TCS: Logistics spawn failed.", 10):ToGroup(group) end
    return nil -- Failed to create task
  end

  function taskHandle:IsOver()
    if self.Status ~= "ACTIVE" then return true, self.Status end
    if timer.getTime() > (self.StartTime + self.Duration) then return true, "TIMEOUT" end
    
    local convoyGroup = self.ConvoyGroups and self.ConvoyGroups[1]
    if not convoyGroup or not convoyGroup:IsAlive() then return true, "DESTROYED" end

    if convoyGroup:GetCoordinate():Get2DDistance(self.Destination) < 500 then
      session:Broadcast("TCS: Convoy arrived! Capabilities restored.", 15)
      convoyGroup:Destroy()
      return true, "ARRIVED"
    end

    return false
  end

  return taskHandle
end

env.info("TCS(A2G.LOGISTICS): ready")