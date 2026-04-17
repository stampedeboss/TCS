---------------------------------------------------------------------
-- TCS UNIFIED CATALOG
-- Implements the map-agnostic, schema-locked object database.
---------------------------------------------------------------------
env.info("TCS(CATALOG): loading")

TCS = TCS or {}
TCS.Catalog = {
  Version = "1.0",
  Entries = {}
}

function TCS.Catalog.Add(entry)
  -- Schema validation could go here
  if not entry.id then env.error("TCS(CATALOG): Entry missing ID") return end
  table.insert(TCS.Catalog.Entries, entry)
end

function TCS.Catalog.Query(filter)
  local results = {}
  for _, entry in ipairs(TCS.Catalog.Entries) do
    local match = true
    if filter then
      for k, v in pairs(filter) do
        -- Check top-level fields first, then tags (for legacy filter support)
        local val = entry[k] or (entry.tags and entry.tags[k])
        if val ~= v then match = false; break end
      end
    end
    if match then table.insert(results, entry) end
  end
  return results
end

--- Queries the catalog and returns a flat list of all unit_type strings from matching entries.
-- Useful for creating randomized pools for spawning mixed groups.
function TCS.Catalog.GetUnitTypeList(filter)
  local entries = TCS.Catalog.Query(filter)
  local types = {}
  for _, entry in ipairs(entries) do
    if entry.unit_types then
      for _, t in ipairs(entry.unit_types) do
        table.insert(types, t)
      end
    end
  end
  return types
end

function TCS.Catalog.FindById(id, tier)
  if not id then return nil end
  
  -- 1. Exact ID Match
  for _, entry in ipairs(TCS.Catalog.Entries) do
    if entry.id == id then
      return entry
    end
  end
  
  -- 2. Category Fallback: If 'id' matches a Category (e.g. INFANTRY, ARMOR), return a virtual entry with the pool.
  -- Optional: Filter by tier if provided to ensure variety matches the requested skill level.
  local filter = { category = id }
  -- Note: Complex filtering (like the threat_band mapping in force_spawner) 
  -- could be added here to further refine the virtual entry.
  local types = TCS.Catalog.GetUnitTypeList(filter)

  if #types > 0 then
    return { id = id, unit_types = types }
  end

  return nil
end

-- Ingest Configuration Data into the Catalog
function TCS.Catalog.Ingest(data)
  if not data then return end

  -- 1. A2G Content
  if data.A2G then
    for category, list in pairs(data.A2G) do
      for _, item in ipairs(list) do
        -- Global Unit Type Validation & Typo Correction
        if item.unit_type == "MT-LB" then item.unit_type = "MTLB" end
        
        if world and world.getDescByName and item.unit_type and not world.getDescByName(item.unit_type) then
          local roleAlts = {
            LN = "2P25", TR = "1S91 str", SR = "p-19 s-125 sr", AAA = "ZU-23 Emplacement",
            MBT = "T-55", IFV = "BMP-2", APC = "BTR-80", TRANSPORT = "Ural-375",
            RIFLEMAN = "Infantry AK", BVR = "MiG-21Bis", AWACS = "A-50", FORTIFICATION = "Container Red 1"
          }
          local fallbacks = (TCS.Config and TCS.Config.CatalogFallbacks) or {}
          local alt = fallbacks[item.unit_type] or roleAlts[item.role] or "Container Red 1"
          env.warning(string.format("TCS(CATALOG): Unit type '%s' not found. Falling back to '%s'.", item.unit_type, alt))
          item.unit_type = alt
        end

        local entry = {
          id = item.id,
          domain = item.domain,
          mobile = (item.mobility ~= "STATIC"),
          late_activation = true,
          unit_types = { item.unit_type },
          first_service_year = item.first_service_year,
          threat = item.role,
          tags = {
            role = item.role,
            mobility = item.mobility,
            threat_band = item.threat_band,
            category = category,
            coalition = item.coalition
          },
          data = { coalition = item.coalition }
        }
        TCS.Catalog.Add(entry)
      end
    end
  end

  -- 2. Air Bandits
  if data.Air_Bandits then
    local skillMap = { ["Average"] = "A", ["Good"] = "G", ["High"] = "H", ["Excellent"] = "X" }
    for _, b in ipairs(data.Air_Bandits) do
      TCS.Catalog.Add({
        id = b.id,
        domain = "AIR",
        mobile = true,
        late_activation = true,
        unit_types = { b.unit_type },
        first_service_year = b.first_service_year,
        threat = "AIR_FIGHTER",
        skill_profile = skillMap[b.skill] or "G",
        tags = { role = b.filters.role, tier = b.filters.tier, type = b.filters.type, coalition = "RED" },
        data = { payload = b.payload, livery = b.livery }
      })
    end
  end

  -- 3. Air Packages
  if data.Air_Packages then
    for _, p in ipairs(data.Air_Packages) do
      TCS.Catalog.Add({
        id = p.id, domain = "AIR", mobile = true, late_activation = true,
        unit_types = { p.unit_type }, threat = "AIR_SUPPORT",
        first_service_year = p.first_service_year,
        tags = { role = p.role, coalition = p.coalition or "BLUE" }, data = { count = p.count, skill = p.skill }
      })
    end
  end
end

env.info("TCS(CATALOG): ready")