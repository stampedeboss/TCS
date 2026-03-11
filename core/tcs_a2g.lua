env.info("TCS(A2G_CORE): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}

--- Broadcasts a message to all members of a session.
-- @param session (table) The session object.
-- @param text (string) The message text.
-- @param duration (number) Duration in seconds.
function TCS.A2G.NotifySession(session, text, duration)
  if not session then return end
  if session.Broadcast then
    session:Broadcast(text, duration)
  end
  if TCS.AWACS and TCS.AWACS.Say then
    TCS.AWACS.Say(text)
  end
end

--- Wipes all TCS-spawned A2G objects (Groups & Statics) from the map.
function TCS.A2G.CleanupAllSpawns()
  local prefix = "TCS_"
  local count = 0

  local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
  local cats = { Group.Category.GROUND, Group.Category.SHIP, Group.Category.TRAIN }

  for _, side in ipairs(sides) do
    -- Groups
    for _, cat in ipairs(cats) do
      local groups = coalition.getGroups(side, cat) or {}
      for _, g in ipairs(groups) do
        if g and g:isExist() and string.sub(g:getName(), 1, #prefix) == prefix then
          g:destroy()
          count = count + 1
        end
      end
    end
    -- Statics
    local statics = coalition.getStaticObjects(side) or {}
    for _, s in ipairs(statics) do
      if s and s:isExist() and string.sub(s:getName(), 1, #prefix) == prefix then
        s:destroy()
        count = count + 1
      end
    end
  end
  
  local msg = string.format("TCS Admin: Wiped %d A2G spawns (Global).", count)
  env.info(msg)
  MESSAGE:New(msg, 10):ToAll()
  return count
end

env.info("TCS(A2G_CORE): ready")