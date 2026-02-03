---------------------------------------------------------------------
-- players.lua
-- Authoritative player lifecycle (Birth-driven)
---------------------------------------------------------------------
env.info("TCS(PLAYERS): loading")

PLAYERS = PLAYERS or {}
PLAYERS.ByName = PLAYERS.ByName or {}

function PLAYERS:GetOrCreate(event)
  local pname = event.IniPlayerName
  if not pname then return nil end

  local rec = self.ByName[pname]
  if rec then
    rec.Unit  = event.IniUnit
    rec.Group = event.IniGroup
    rec.Coalition = event.IniCoalition
    return rec
  end

  rec = {
    Name = pname,
    Unit = event.IniUnit,
    Group = event.IniGroup,
    Coalition = event.IniCoalition,
    Menus = {},
    ActiveModes = {},
    ActiveBandits = {},
    Cooldowns = {},
    Session = nil,
  }

  self.ByName[pname] = rec
  env.info("Player record Created")

  if TCS.Menu and TCS.Menu.BuildForPlayer then
    SCHEDULER:New(nil, function()
      if not rec.Unit or not rec.Unit:IsAlive() then return end
      if not rec.Group or not rec.Group:IsAlive() then return end
      TCS.Menu.BuildForPlayer(rec)
    end, {}, 0.1)
    env.info("Player Menus Created")
  end
  return rec
end

PLAYERS.Handler = EVENTHANDLER:New()
PLAYERS.Handler:HandleEvent(EVENTS.Birth)

function PLAYERS.Handler:OnEventBirth(event)
  if not event.IniUnit or not event.IniPlayerName then return end
  PLAYERS:GetOrCreate(event)
end

function PLAYERS:GetByGroup(group)
  if not group then return nil end
  -- Attempt to resolve player record from the group's first unit
  local unit = group:GetUnit(1)
  local pName = unit and unit:GetPlayerName()
  if pName and self.ByName then
    return self.ByName[pName]
  end
  return nil
end

function PLAYERS:OnCooldown(rec, key)
  if not rec or not rec.Cooldowns then return false, 0 end
  local t = rec.Cooldowns[key] or 0
  local now = timer.getTime()
  if now < t then return true, math.ceil(t - now) end
  return false, 0
end

function PLAYERS:MarkAction(rec, key, duration)
  if not rec then return end
  rec.Cooldowns = rec.Cooldowns or {}
  rec.Cooldowns[key] = timer.getTime() + (duration or 0)
end

env.info("TCS(PLAYERS): ready")
