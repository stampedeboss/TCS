---------------------------------------------------------------------
-- TCS SIGNALS: F10 MAP
-- Handles drawing tactical boundaries and labels on the F10 map.
---------------------------------------------------------------------
env.info("TCS(SIGNALS.F10): loading")

TCS = TCS or {}
TCS.Signals = TCS.Signals or {}
TCS.Signals.F10 = {}
TCS.Signals.F10._NextMarkID = 2850000 

function TCS.Signals.F10.GetNextMarkID()
  TCS.Signals.F10._NextMarkID = TCS.Signals.F10._NextMarkID + 1
  return TCS.Signals.F10._NextMarkID
end

TCS.Signals.F10.ActiveDrawings = TCS.Signals.F10.ActiveDrawings or {}

function TCS.Signals.F10.Draw(zoneId, tag, coord, echelon, radius, zoneName, heading, arc)
  if not zoneId or not coord then return end
  
  -- Prioritize the explicit zone name passed from the Architect
  local z = (zoneName and ZONE:FindByName(zoneName)) or ZONE:FindByName(tag) or ZONE:FindByName(coord:ToStringMGRS())
  
  TCS.Signals.F10.ActiveDrawings[zoneId] = TCS.Signals.F10.ActiveDrawings[zoneId] or {}

  local dcsZone = z and trigger.misc.getZone(z:GetName())
  local drawRadius = radius or 5000
  
  if dcsZone and dcsZone.vertices and #dcsZone.vertices > 1 then
      local v = dcsZone.vertices
      local color = {1,0,0,0.6} -- Semi-transparent red
      
      -- Iterate through all vertices to draw the polygon outline
      for i = 1, #v do
          local p1 = v[i]
          local p2 = v[i % #v + 1] -- Loop back to the first vertex to close the shape
          local markId = TCS.Signals.F10.GetNextMarkID()
          trigger.action.lineToAll(-1, markId, {x=p1.x, y=land.getHeight(p1)+5, z=p1.z}, {x=p2.x, y=land.getHeight(p2)+5, z=p2.z}, color, 3, true)
          table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], markId)
      end
  else
      local mid = TCS.Signals.F10.GetNextMarkID()
      trigger.action.circleToAll(-1, mid, coord:GetVec3(), drawRadius, {1,0,0,1}, {0,0,0,0}, 3, true)
      table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], mid)
  end

  if heading then
      local vid = TCS.Signals.F10.GetNextMarkID()
      local vLen = radius or 5000
      local fromPt = coord:Translate(vLen * 2, heading):GetVec3()
      local toPt = coord:Translate(vLen, (heading + 180) % 360):GetVec3()
      trigger.action.lineToAll(-1, vid, fromPt, toPt, {1,1,1,0.4}, 2, true)
      table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], vid)

      local hid1, hid2 = TCS.Signals.F10.GetNextMarkID(), TCS.Signals.F10.GetNextMarkID()
      local h1 = coord:Translate(vLen * 0.2, (heading + 150) % 360):GetVec3()
      local h2 = coord:Translate(vLen * 0.2, (heading + 210) % 360):GetVec3()
      trigger.action.lineToAll(-1, hid1, coord:GetVec3(), h1, {1,1,1,0.6}, 1, true)
      trigger.action.lineToAll(-1, hid2, coord:GetVec3(), h2, {1,1,1,0.6}, 1, true)
      table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], hid1); table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], hid2)
  end

  local lid = TCS.Signals.F10.GetNextMarkID()
  local text = string.format("%s: %s\n%s", tag, echelon or "Standard", coord:ToStringMGRS())
  trigger.action.textToAll(-1, lid, coord:GetVec3(), {1,1,1,1}, {0,0,0,0.5}, 12, text, true)
  table.insert(TCS.Signals.F10.ActiveDrawings[zoneId], lid)
end

--- Clears all drawings for a specific zone
function TCS.Signals.F10.ClearZone(zoneId)
  if not TCS.Signals.F10.ActiveDrawings[zoneId] then return end
  for _, markId in ipairs(TCS.Signals.F10.ActiveDrawings[zoneId]) do
      trigger.action.removeMark(markId)
  end
  TCS.Signals.F10.ActiveDrawings[zoneId] = nil
end

env.info("TCS(SIGNALS.F10): ready")