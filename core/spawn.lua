
env.info("TCS(A2G.SPAWN): loading")
TCS=TCS or {}; TCS.A2G=TCS.A2G or {}; TCS.A2G.Spawn={}

function TCS.A2G.Spawn.Group(groupName, coord, opts)
  opts = opts or {}
  local tpl = GROUP:FindByName(groupName)
  if not tpl then return end
  local g = tpl:CopyToCoalition(opts.coalition or coalition.side.RED)
  if coord then g:SetCoordinate(coord) end
  return g
end
