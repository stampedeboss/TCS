
env.info("TCS(A2G.FORCE_SPAWNER): loading")
TCS.A2G.ForceSpawner={}

local function pick(tbl) return tbl[math.random(#tbl)] end


function TCS.A2G.ForceSpawner.Spawn(session,forceName,echelonName,anchor,opts)
  opts = opts or {}
  local force=TCS.A2G.Forces[forceName]
  local ech=TCS.Config.Echelons[echelonName]
  if not force or not ech then return nil end
  local idx=0
  local spawned = {}
  local conditions = opts.conditions
  
  -- Filter pool by tier if provided
  local tier = opts.tier
  local allowedBands = nil
  if tier == "A" then allowedBands = {LOW=true, NONE=true}
  elseif tier == "G" then allowedBands = {LOW=true, MED=true, NONE=true}
  elseif tier == "H" then allowedBands = {LOW=true, MED=true, HIGH=true, NONE=true}
  elseif tier == "X" then allowedBands = {LOW=true, MED=true, HIGH=true, NONE=true}
  end

  for cat,w in pairs(force) do
    local pool = TCS.Catalog.Query({category = cat})
    
    if pool and #pool > 0 and allowedBands then
       local filtered = {}
       for _, entry in ipairs(pool) do
          local band = (entry.tags and entry.tags.threat_band) or "LOW"
          if allowedBands[band] then table.insert(filtered, entry) end
       end
       if #filtered > 0 then pool = filtered end
    end

    -- Filter out carriers unless explicitly requested (prevents CVNs appearing in generic ship groups)
    if pool and #pool > 0 and type(cat) == "string" and not string.find(string.upper(cat), "CARRIER") then
       local nonCarriers = {}
       for _, entry in ipairs(pool) do
          local isCarrier = false
          if entry.unit_types then
             for _, uType in ipairs(entry.unit_types) do
                local u = string.upper(uType)
                if string.find(u, "CVN") or string.find(u, "LHA") or string.find(u, "STENNIS") or string.find(u, "TARAWA") or string.find(u, "KUZNETSOV") or string.find(u, "KUZNECOV") or string.find(u, "VINSON") or string.find(u, "CV_") or string.find(u, "FORRESTAL") then
                   isCarrier = true; break
                end
             end
          end
          if not isCarrier then table.insert(nonCarriers, entry) end
       end
       if #nonCarriers > 0 then 
          pool = nonCarriers 
       else
          env.warning("TCS.ForceSpawner: Requested non-carrier ship group, but only carriers found in catalog for category: " .. tostring(cat))
       end
    end

    if pool and #pool > 0 then
      local val = w * ech.scale
      local cnt = math.floor(val)
      if math.random() < (val - cnt) then
        cnt = cnt + 1
      end
      for i=1,cnt do
        idx=idx+1
        local comp=pick(pool)
        if type(comp) == "table" and comp.unit_types and #comp.unit_types > 0 then
          local pos = nil
          -- Attempt to find a valid position for this component's domain
          local distScale = 1.0
          if comp.speed_class == "SLOW" then
             distScale = 0.5
          elseif comp.speed_class == "FAST" then
             distScale = 1.5
          end

          for attempt=1, 10 do
             -- Apply speed-based scaling to spacing
             local dist = idx * ech.spacing * distScale
             -- Ensure minimum safe distance (e.g. 2km)
             dist = math.max(2000, dist)
             local p = anchor:Translate(dist, math.random(0,359))
             if TCS.Placement.Validate(p, comp.domain, conditions) then
               pos = p
               break
             end
          end
          
          if pos then
            local spawnOpts = {}
            for k,v in pairs(opts) do spawnOpts[k] = v end
            spawnOpts.formation = comp.spacing_class or "COLUMN"
            spawnOpts.spacing = comp.spacing_class -- Note: spacing_class is not in catalog schema yet

            -- Apply 3-level naming convention
            local alias = string.format("%s_%s_%d", forceName, comp.id or "unknown", idx)
            if session and session.Name then
              spawnOpts.name = string.format("TCS_%s_%s", session.Name, alias)
            else
              spawnOpts.name = string.format("TCS_GLOBAL_%s", alias)
            end

            local unitType = comp.unit_types[1]
            -- Determine category from domain
            local spawnCat = "GROUND"
            if comp.domain == "SEA" then spawnCat = "SHIP" end
            if comp.mobile == false then spawnCat = "STRUCTURE" end
            
            local obj = TCS.Spawn.Group(unitType, pos, spawnOpts, spawnCat, comp.size or 1)
            if obj then table.insert(spawned, obj) end
          end
        end
      end
    end
  end
  return spawned
end
