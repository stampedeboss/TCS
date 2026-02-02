
env.info("TCS(A2G.FORCE_SPAWNER): loading")
TCS.A2G.ForceSpawner={}

local function pick(tbl) return tbl[math.random(#tbl)] end

function TCS.A2G.ForceSpawner.Spawn(forceName,echelonName,anchor,opts)
  local force=TCS.A2G.Forces[forceName]
  local ech=TCS.A2G.Echelons[echelonName]
  if not force or not ech then return end
  local idx=0
  for cat,w in pairs(force) do
    local pool=TCS.A2G.Components[cat]
    if pool then
      local cnt=math.max(1,math.floor(w*ech.scale))
      for i=1,cnt do
        idx=idx+1
        local g=pick(pool)
        local pos=anchor:Translate(idx*ech.spacing,math.random(0,359))
        TCS.A2G.Spawn.Group(g,pos,opts)
      end
    end
  end
end
