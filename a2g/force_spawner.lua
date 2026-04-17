
env.info("TCS(A2G.FORCE_SPAWNER): loading")
TCS.A2G.ForceSpawner={}

local function pick(tbl) return tbl[math.random(#tbl)] end


function TCS.A2G.ForceSpawner.Spawn(session,forceOrName,echelonName,anchor,opts)
  opts = opts or {}
  local force = type(forceOrName) == "table" and forceOrName or TCS.A2G.Forces[forceOrName]
  local forceLabel = opts.forceName or (type(forceOrName) == "string" and forceOrName) or "CUSTOM"
  local ech=TCS.A2G.Echelons[echelonName]
  if not force or not ech then return nil end
  local idx=0
  local spawned = {}
  local conditions = opts.conditions
  
  -- Resolve Mission Year from flag
  local missionYear = 0
  if TCS.A2G.Config and TCS.A2G.Config.MISSION_YEAR_FLAG then
    missionYear = trigger.misc.getUserFlag(TCS.A2G.Config.MISSION_YEAR_FLAG)
  end

  -- Filter pool by tier if provided
  local tiers = type(opts.tier) == "table" and opts.tier or {opts.tier}
  local allowedBands = {}
  local hasFilter = false

  for _, t in ipairs(tiers) do
    if t == "A" then allowedBands.LOW=true; allowedBands.NONE=true; hasFilter = true
    elseif t == "G" then allowedBands.LOW=true; allowedBands.MED=true; allowedBands.NONE=true; hasFilter = true
    elseif t == "H" or t == "X" then allowedBands.LOW=true; allowedBands.MED=true; allowedBands.HIGH=true; allowedBands.NONE=true; hasFilter = true
    end
  end

  for cat,w in pairs(force) do
    local coalStr = (opts.coalition == coalition.side.BLUE) and "BLUE" or "RED"
    
    -- Standardize category name and handle common typos
    local searchCat = string.upper(cat)
    if searchCat == "INFRA" then searchCat = "INFANTRY" end
    if searchCat == "STRUC" then searchCat = "STRUCTURE" end

    local pool = TCS.Catalog.Query({category = searchCat, coalition = coalStr})
    
    if not pool or #pool == 0 then
      env.error(string.format("TCS(FORCE_SPAWNER): Catalog query for category '%s' returned 0 units. Check catalog_data.lua!", tostring(cat)))
    end

    -- Era Filter (Mission Year)
    if pool and #pool > 0 and missionYear > 0 then
       local eraFiltered = {}
       for _, entry in ipairs(pool) do
          local serviceYear = entry.first_service_year or 0
          -- If service year is 0, we assume it's always available (e.g. bunkers/containers)
          if serviceYear == 0 or serviceYear <= missionYear then
             table.insert(eraFiltered, entry)
          end
       end
       pool = eraFiltered
    end

    if pool and #pool > 0 and hasFilter then
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
      -- Aggregate unit types from the filtered pool candidates only.
      -- This ensures that variety strictly respects Mission Year and Difficulty Tier (Threat Band).
      local unitTypesPool = {}
      for _, entry in ipairs(pool) do
        local w = entry.weight or 1
        if entry.unit_types then
          for _, ut in ipairs(entry.unit_types) do table.insert(unitTypesPool, ut) end
          for i = 1, w do
            for _, ut in ipairs(entry.unit_types) do table.insert(unitTypesPool, ut) end
          end
        end
      end

      -- If absoluteCount is true, ignore the echelon scale multiplier
      local val = w * (opts.absoluteCount and 1 or ech.scale)
      local cnt = math.floor(val)
      if math.random() < (val - cnt) then
        cnt = cnt + 1
      end

      if cnt > 0 then
        idx = idx + 1
        local comp = pick(pool)
        if type(comp) == "table" and comp.unit_types and #comp.unit_types > 0 then
          -- Use the category-wide pool for variety if available, otherwise fall back to the specific entry's types
          local typeOrPool = (#unitTypesPool > 0) and unitTypesPool or comp.unit_types

          local pos = nil
          
          -- Determine category from domain to check for Static vs Mobile
          local spawnCat = "GROUND"
          if comp.domain == "SEA" then spawnCat = "SHIP" end
          if comp.domain == "AIR" then spawnCat = "AIR" end
          if comp.mobile == false then spawnCat = "STRUCTURE" end

          -- Attempt to find a valid position for the entire group
          local distScale = 1.0
          if comp.speed_class == "SLOW" then distScale = 0.5
          elseif comp.speed_class == "FAST" then distScale = 1.5 end

          for attempt=1, 20 do
            -- Space out group anchors relative to each other (idx * spacing * 5)
            -- This ensures the Armor group and SAM group aren't on top of each other.
            local dist = (idx * ech.spacing * 5 * distScale) + math.random(0, 500)
            dist = math.max(2000, dist)
            local p = anchor:Translate(dist, math.random(0,359))
            if TCS.Placement.Validate(p, comp.domain, conditions) then
              pos = p
              break
            end
          end

          if not pos then
            env.warning(string.format("TCS(FORCE_SPAWNER): Placement failed for group %d (%s) after 20 attempts.", idx, tostring(unitType or "unknown")))
          end
          
          if pos then
            local spawnOpts = {}
            for k,v in pairs(opts) do spawnOpts[k] = v end
            spawnOpts.formation = comp.spacing_class or "COLUMN"
            spawnOpts.spacing = comp.spacing_class -- Note: spacing_class is not in catalog schema yet

            -- Apply 3-level naming convention
            local alias = string.format("%s_%s_%d", forceLabel, comp.id or "unknown", idx)
            if session and session.Name then
              spawnOpts.name = string.format("TCS_%s_%s", session.Name, alias)
            else
              spawnOpts.name = string.format("TCS_GLOBAL_%s", alias)
            end

            -- Statics (Structures) still spawn individually to prevent stacking models
            -- Mobile units now spawn as a single cohesive group of 'cnt' units.
            if spawnCat == "STRUCTURE" then
              for i=1, cnt do
                local obj = TCS.Spawn.Group(typeOrPool, pos:Translate(i*20, 0), spawnOpts, spawnCat, 1)
                if obj then table.insert(spawned, obj) end
              end
            else
              local obj = TCS.Spawn.Group(typeOrPool, pos, spawnOpts, spawnCat, cnt)
              if obj then table.insert(spawned, obj) end
            end
          end
        end
      end
    end
  end
  return spawned
end
