---------------------------------------------------------------------
-- TCS UNIFIED CONTROLLER
--
-- Purpose:
--   Central brain for cross-domain logic.
--   Orchestrates interactions between A2A, A2G, and Logistics.
---------------------------------------------------------------------
env.info("TCS(CONTROLLER): loading")

TCS = TCS or {}
TCS.Controller = {
  ActiveModes = {}, -- [sessionName] = { mode1, mode2, ... }
  Taskings = {}     -- [id] = { Type, Desc, Location, OnAccept }
}

--- Registers an active mode (CAS, CAP, etc) with the controller.
function TCS.Controller:Register(session, mode)
  if not session or not mode then return end
  local sName = session.Name
  self.ActiveModes[sName] = self.ActiveModes[sName] or {}
  table.insert(self.ActiveModes[sName], mode)
end

--- Handles high-level events from subsystems.
-- @param event (string) Event name (e.g. "CAS_RETREAT")
-- @param params (table) Context data
function TCS.Controller:OnEvent(event, params)
  env.info("TCS(CONTROLLER): Event " .. tostring(event))
  
  if event == "CAS_RETREAT" then
    self:HandleCasRetreat(params)
  elseif event == "ESCORT_START" then
    self:HandleEscortStart(params)
  elseif event == "A2G_START" then
    self:HandleA2GStart(params)
  end
end

--- Adds a tasking to the board.
function TCS.Controller:AddTasking(type, desc, location, onAcceptFn)
  local id = math.random(1000, 9999)
  self.Taskings[id] = {
    ID = id,
    Type = type,
    Desc = desc,
    Location = location,
    OnAccept = onAcceptFn,
    Timestamp = timer.getTime()
  }
  
  local msg = string.format("TASKING BOARD: New Tasking [%d]\nType: %s\nDesc: %s", id, type, desc)
  env.info("TCS(CONTROLLER): " .. msg)
  if MESSAGE then
    MESSAGE:New(msg, 15):ToAll()
  else
    trigger.action.outText(msg, 15)
  end
  return id
end

--- Accepts a tasking.
function TCS.Controller:AcceptTasking(id, group, mode)
  local t = self.Taskings[id]
  if not t then return false, "Tasking not found or already taken." end
  if t.OnAccept then t.OnAccept(group, mode) end
  self.Taskings[id] = nil
  return true, "Tasking accepted."
end

--- Periodically removes old, unaccepted taskings to prevent memory leaks.
function TCS.Controller:MonitorTaskings()
  local now = timer.getTime()
  local timeout = 3600 -- 1 hour
  for id, t in pairs(self.Taskings) do
    if now - t.Timestamp > timeout then
      self.Taskings[id] = nil
    end
  end
  return now + 300 -- Check every 5 minutes
end

---------------------------------------------------------------------
-- Scenario Logic: CAS Extraction
---------------------------------------------------------------------

function TCS.Controller:HandleCasRetreat(params)
  local session = params.session
  local location = params.location -- Coordinate of retreat
  local group = params.group -- Player group to notify

  if not session or not location then return end

  -- 1. Notify
  local msg = "COMMAND: CAS forces are overrun! Requesting immediate extraction."
  session:Broadcast(msg, 10)
  if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(msg) end
  
  -- 2. Post Tasking to Board
  self:AddTasking("CAS_EXTRACT", "Escort C-130 to extraction point", location, function(playerGroup, mode)
    if mode == "PLAYER" then
      if TCS.A2A and TCS.A2A.ESCORT and TCS.A2A.ESCORT.Start then
        local s = TCS.SessionManager:GetOrCreateSessionForGroup(playerGroup)
        local r = { Session = s, Group = playerGroup, Unit = playerGroup:GetUnit(1) }
        TCS.A2A.ESCORT:Start(r, "TRANSPORT", 1200, "G", location)
      end
    elseif mode == "AI" then
      -- Placeholder for AI dispatch logic
      if session then
        local aiMsg = "COMMAND: AI Assets dispatched for extraction."
        session:Broadcast(aiMsg, 10)
        if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(aiMsg) end
      end
    end
  end)
end

---------------------------------------------------------------------
-- Scenario Logic: Escort Target Generation
---------------------------------------------------------------------

function TCS.Controller:HandleEscortStart(params)
  local session = params.session
  local dest = params.destination
  local pkgType = params.type -- e.g. "STRIKE", "CAS", "BOMBER"

  if not session or not dest then return end

  -- If we are escorting a strike/bomber package, ensure there is something to bomb at the destination
  if pkgType == "STRIKE" or pkgType == "BOMBER" or pkgType == "STRIKE_F18" or pkgType == "STRIKE_A10" then
    local surf = land.getSurfaceType({x=dest.x, y=dest.z})
    
    if surf == land.SurfaceType.WATER then
      if TCS.SUW and TCS.SUW.Start then
        local msg = "INTEL: Escorted package enroute to naval targets."
        session:Broadcast(msg, 10)
        if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(msg) end
        TCS.SUW.Start(session, dest, "MAR_HARBOR", "Naval Strike", false, nil, "PLATOON")
      end
    else
      if TCS.A2G and TCS.A2G.STRIKE and TCS.A2G.STRIKE.Start then
        local msg = "INTEL: Escorted package enroute to ground targets."
        session:Broadcast(msg, 10)
        if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(msg) end
        TCS.A2G.STRIKE.Start(session, dest, "PLATOON", nil)
      end
    end

  elseif pkgType == "CAS" or pkgType == "STRIKE_A10" then
    if TCS.A2G and TCS.A2G.CAS and TCS.A2G.CAS.Start then
      local msg = "INTEL: Escorted package enroute to active TIC."
      session:Broadcast(msg, 10)
      if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(msg) end
      TCS.A2G.CAS.Start(session, dest, "PLATOON", nil)
    end
  end
end

---------------------------------------------------------------------
-- Scenario Logic: A2G Reaction (Enemy CAP)
---------------------------------------------------------------------

function TCS.Controller:HandleA2GStart(params)
  local session = params.session
  local anchor = params.anchor
  
  -- 40% chance the enemy launches a defensive CAP over the target area
  if math.random() < 0.40 and TCS.A2A and TCS.A2A.CAP and TCS.A2A.CAP.StartAt then
    local msg = "WARNING: Enemy Air Response detected launching!"
    session:Broadcast(msg, 15)
    if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(msg) end
    TCS.A2A.CAP:StartAt(session, anchor, 3600, nil, "G")
  end
end

-- Start the monitor
timer.scheduleFunction(function(_, t) return TCS.Controller:MonitorTaskings() end, nil, timer.getTime() + 300)

env.info("TCS(CONTROLLER): ready")