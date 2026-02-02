
---------------------------------------------------------------------
-- TCS A2G JTAC Controller
--
-- Supports CAS 9-Line tasking with pilot-selectable marking:
--   Default: SMOKE
--   Options: SMOKE / IR / LASER
--   LASER uses default code unless pilot specifies otherwise
---------------------------------------------------------------------

A2G_JTAC = A2G_JTAC or {}

-- Defaults
A2G_JTAC.DefaultMark = "SMOKE"
A2G_JTAC.DefaultLaserCode = 1688

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function say(session, msg, t)
  if TCS_COMMS and TCS_COMMS.SayToSession then
    TCS_COMMS.SayToSession(session, msg, t or 10)
  end
end

---------------------------------------------------------------------
-- Friendly marking
---------------------------------------------------------------------

function A2G_JTAC.MarkFriendlies(session, groups, mark, laserCode)
  mark = mark or A2G_JTAC.DefaultMark
  laserCode = laserCode or A2G_JTAC.DefaultLaserCode

  for _, g in ipairs(groups or {}) do
    if g and g.GetCoordinate then
      local coord = g:GetCoordinate():GetVec2()
      if mark == "SMOKE" then
        trigger.action.smoke(coord, trigger.smokeColor.Green)
      elseif mark == "IR" then
        trigger.action.illuminationBomb(coord, 2000)
      elseif mark == "LASER" then
        -- Placeholder: DCS laser is conceptual here; message conveys code
      end
    end
  end

  local msg = "JTAC: Friendlies marked by " .. mark
  if mark == "LASER" then
    msg = msg .. " code " .. tostring(laserCode)
  end
  say(session, msg, 10)
end

---------------------------------------------------------------------
-- CAS 9-Line briefing
---------------------------------------------------------------------

function A2G_JTAC.BriefCAS(session, data)
  -- data fields expected:
  -- ip, heading, distance, elevation, targetDesc, grid, mark, friendlies, egress, remarks

  local lines = {}

  table.insert(lines, "JTAC: CAS 9-line.")
  if data.ip then table.insert(lines, "1. IP " .. data.ip) end
  if data.heading and data.distance then
    table.insert(lines, "2. Heading " .. data.heading .. ", distance " .. data.distance)
  end
  if data.elevation then table.insert(lines, "3. Elevation " .. data.elevation) end
  if data.targetDesc then table.insert(lines, "4. " .. data.targetDesc) end
  if data.grid then table.insert(lines, "5. Target location " .. data.grid) end
  if data.mark then table.insert(lines, "6. Marked by " .. data.mark) end
  if data.friendlies then table.insert(lines, "7. Friendlies " .. data.friendlies) end
  if data.egress then table.insert(lines, "8. Egress " .. data.egress) end
  if data.remarks then table.insert(lines, "9. Remarks " .. data.remarks) end

  for _, l in ipairs(lines) do
    say(session, l, 12)
  end
end

---------------------------------------------------------------------
-- Pilot selection helpers (menus wired elsewhere)
---------------------------------------------------------------------

function A2G_JTAC.SetDefaultMark(session, mark)
  session.A2G = session.A2G or {}
  session.A2G.Mark = mark
end

function A2G_JTAC.GetDefaultMark(session)
  return (session.A2G and session.A2G.Mark) or A2G_JTAC.DefaultMark
end
