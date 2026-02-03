
env.info("TCS(A2G.FORCE_SPAWNER): loading")
TCS.A2G.ForceSpawner={}

local function pick(tbl) return tbl[math.random(#tbl)] end


function TCS.A2G.ForceSpawner.Spawn(session,forceName,echelonName,anchor,opts)
  local force=TCS.A2G.Forces[forceName]
  local ech=TCS.A2G.Echelons[echelonName]
  if not force or not ech then return nil end
  local idx=0
  local spawned = {}
  for cat,w in pairs(force) do
    local pool=TCS.A2G.Components[cat]
    if pool then
      local cnt=math.max(1,math.floor(w*ech.scale))
      for i=1,cnt do
        idx=idx+1
        local comp=pick(pool)
        if type(comp) == "table" and comp.unit_type then
          local pos = nil
          -- Attempt to find a valid position for this component's domain
          for attempt=1, 10 do
             local p = anchor:Translate(idx*ech.spacing, math.random(0,359))
             if TCS.Placement.Validate(p, comp.domain) then
               pos = p
               break
             end
          end
          
          if pos then
            local spawnOpts = opts
            spawnOpts.formation = comp.spacing_class or "COLUMN"
            spawnOpts.spacing = comp.spacing_class

            local obj = TCS.Spawn.Group(comp.unit_type,pos,spawnOpts,cat,comp.size)
            if obj then
              if session and TCS.A2G.Registry then TCS.A2G.Registry:Register(session, obj) end
              table.insert(spawned, obj)
            end
          end
        end
      end
    end
  end
  return spawned
end
