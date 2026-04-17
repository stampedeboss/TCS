---------------------------------------------------------------------
-- TCS COMMON SCENARIO: F10 VISUALS
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Scenario = TCS.Common.Scenario or {} -- Ensure parent table exists
TCS.Common.Scenario.F10 = {}
TCS.Common.Scenario.F10._NextMarkID = 2850000 

function TCS.Common.Scenario.F10.GetNextMarkID()
  TCS.Common.Scenario.F10._NextMarkID = TCS.Common.Scenario.F10._NextMarkID + 1
  return TCS.Common.Scenario.F10._NextMarkID
end

function TCS.Common.Scenario.F10.Draw(session, tag, coord, echelon, radius, zoneName, heading, arc)
  if not session or not coord then return end
  
  -- Attempt to find the zone to determine shape
  local z = ZONE:FindByName(tag) or ZONE:FindByName(coord:ToStringMGRS()) -- fallback lookup
  
  session[tag .. "_Drawings"] = session[tag .. "_Drawings"] or {}
  local mid, lid = TCS.Common.Scenario.F10.GetNextMarkID(), TCS.Common.Scenario.F10.GetNextMarkID()

  -- If it's a Quad/Square zone, draw it accurately
  local dcsZone = z and trigger.misc.getZone(z:GetName())
  local drawRadius = radius or 5000
  if dcsZone and dcsZone.vertices then
      local v = dcsZone.vertices
      -- Quad drawing requires 4 points
      trigger.action.quadToAll(-1, mid, v[1], v[2], v[3], v[4], {1,0,0,1}, {0,0,0,0}, 3, true)
  else
      -- Default to circle for circular zones or coordinate-only anchors
      trigger.action.circleToAll(-1, mid, coord:GetVec3(), drawRadius, {1,0,0,1}, {0,0,0,0}, 3, true)
  end

  -- Draw Ingress Vector and Arc Highlights
  if heading then
      local vid = TCS.Common.Scenario.F10.GetNextMarkID()
      local vLen = radius or 5000
      -- Main approach line: dashes from spawn direction through the center
      local fromPt = coord:Translate(vLen * 2, heading):GetVec3()
      local toPt = coord:Translate(vLen, (heading + 180) % 360):GetVec3()
      trigger.action.lineToAll(-1, vid, fromPt, toPt, {1,1,1,0.4}, 2, true)
      table.insert(session[tag .. "_Drawings"], vid)

      -- Create a small arrowhead at the center point to indicate "Advance To"
      local hid1, hid2 = TCS.Common.Scenario.F10.GetNextMarkID(), TCS.Common.Scenario.F10.GetNextMarkID()
      local h1 = coord:Translate(vLen * 0.2, (heading + 150) % 360):GetVec3()
      local h2 = coord:Translate(vLen * 0.2, (heading + 210) % 360):GetVec3()
      trigger.action.lineToAll(-1, hid1, coord:GetVec3(), h1, {1,1,1,0.6}, 1, true)
      trigger.action.lineToAll(-1, hid2, coord:GetVec3(), h2, {1,1,1,0.6}, 1, true)
      table.insert(session[tag .. "_Drawings"], hid1); table.insert(session[tag .. "_Drawings"], hid2)

      if arc and arc > 0 then
          local aid1, aid2 = TCS.Common.Scenario.F10.GetNextMarkID(), TCS.Common.Scenario.F10.GetNextMarkID()
          local p1 = coord:Translate(vLen * 1.5, (heading - arc/2) % 360):GetVec3()
          local p2 = coord:Translate(vLen * 1.5, (heading + arc/2) % 360):GetVec3()
          trigger.action.lineToAll(-1, aid1, coord:GetVec3(), p1, {1,1,0,0.25}, 3, true)
          trigger.action.lineToAll(-1, aid2, coord:GetVec3(), p2, {1,1,0,0.25}, 3, true)
          table.insert(session[tag .. "_Drawings"], aid1); table.insert(session[tag .. "_Drawings"], aid2)
      end
  end

  local text = string.format("%s: %s\n%s", tag, echelon or "Standard", coord:ToStringMGRS())
  trigger.action.textToAll(-1, lid, coord:GetVec3(), {1,1,1,1}, {0,0,0,0.5}, 12, text, true)
  table.insert(session[tag .. "_Drawings"], mid); table.insert(session[tag .. "_Drawings"], lid)
end