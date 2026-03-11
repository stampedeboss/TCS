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

function TCS.A2G.LOGISTICS.Start(session, destination, echelon, group)
  -- 1. Standard Scenario Setup
  -- Bias=false because logistics usually targets a specific friendly asset/base
  destination = TCS.Scenario.Setup(session, TAG, destination, group, {Bias=false, domain="A2G"})
  if not destination then return end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  -- Calculate Source (Rear area)
  -- Source is 15-20 NM "behind" the destination relative to group heading
  local hdg = 0
  if group then 
    local u = group:GetUnit(1)
    if u then hdg = u:GetHeading() end
  end
  
  local dist = math.random(15, 20) * 1852
  local source = destination:Translate(dist, (hdg + 180) % 360)

  -- Visual Mark (Friendly Start)
  trigger.action.smoke(source:GetVec3(), trigger.smokeColor.Blue)

  -- Spawn Force
  local force = TCS.A2G.ForceSpawner.Spawn(session, TAG, echelon, source, {coalition=session.Coalition or coalition.side.BLUE})
  
  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, destination, echelon, 5000, {0,0,1,1}, {0,0,1,0.15})

  if force and #force > 0 then
    -- Route to destination
    local speedKph = 40
    local speedMs = speedKph / 3.6
    
    for _, g in ipairs(force) do
      if g and g.TaskRouteToVec2 then
        g:TaskRouteToVec2(destination:GetVec2(), speedMs, "On Road")
        TCS.A2G.LOGISTICS.MonitorArrival(session, g, destination)
      end
    end

    if group then MESSAGE:New("TCS: Supply convoy dispatched from rear area.", 10):ToGroup(group) end
  else
    if group then MESSAGE:New("TCS: Logistics spawn failed.", 10):ToGroup(group) end
  end
end

function TCS.A2G.LOGISTICS.MonitorArrival(session, mooseGroup, destCoord)
  local gName = mooseGroup:GetName()
  
  local function check()
    local g = GROUP:FindByName(gName)
    if not session.ActiveScenarios or not session.ActiveScenarios[TAG] then return end -- Stop if scenario ended
    if not g or not g:IsAlive() then return end -- Destroyed
    
    local curr = g:GetCoordinate()
    if curr:Get2DDistance(destCoord) < 500 then -- Arrived
      if session and session.Owner then
        local ownerGroup = session.Members[session.Owner]
        if ownerGroup then
          MESSAGE:New("TCS: Convoy arrived! Capabilities restored.", 15):ToGroup(ownerGroup)
        end
      end
      -- Restoration logic would trigger here
      g:Destroy() 
      return
    end
    
    timer.scheduleFunction(check, nil, timer.getTime() + 30)
  end
  
  timer.scheduleFunction(check, nil, timer.getTime() + 30)
end

function TCS.A2G.LOGISTICS.MenuRequest(group)
  if not group then return end
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end

  local echelon = nil
  local anchor = TCS.Placement and TCS.Placement.Resolve and TCS.Placement.Resolve(group:GetUnit(1)) or group:GetUnit(1):GetCoordinate()
  
  if anchor then
    TCS.A2G.LOGISTICS.Start(session, anchor, echelon, group)
  end
end

env.info("TCS(A2G.LOGISTICS): ready")