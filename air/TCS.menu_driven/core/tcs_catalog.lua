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

function TCS.Catalog.FindById(id)
  if not id then return nil end
  -- This is a hot path, so optimize for direct lookup if we build an index later.
  -- For now, a linear scan is acceptable.
  for _, entry in ipairs(TCS.Catalog.Entries) do
    if entry.id == id then
      return entry
    end
  end
  return nil
end

-- Ingest Configuration Data into the Catalog
function TCS.Catalog.Ingest(data)
  if not data then return end

  -- 1. A2G Content
  if data.A2G then
    -- 476 Mod Validation & Fallback
    if data.A2G.RANGE_476 and world and world.getDescByName then
      local Fallbacks = TCS.Config.CatalogFallbacks or {}

      for _, item in ipairs(data.A2G.RANGE_476) do
        if not world.getDescByName(item.unit_type) then
          local alt = Fallbacks[item.unit_type] or "Container Red 1"
          env.warning("TCS(CATALOG): 476 Target '" .. item.unit_type .. "' not found. Fallback to '" .. alt .. "'.")
          item.unit_type = alt
        end
      end
    end

    for category, list in pairs(data.A2G) do
      for _, item in ipairs(list) do
        local entry = {
          id = item.id,
          domain = item.domain,
          mobile = (item.mobility ~= "STATIC"),
          late_activation = true,
          unit_types = { item.unit_type },
          threat = item.role,
          tags = {
            role = item.role,
            mobility = item.mobility,
            threat_band = item.threat_band,
            category = category
          },
          data = { coalition = item.coalition }
        }
        TCS.Catalog.Add(entry)
      end
    end
  end

  -- 2. A2A Bandits
  if data.A2A_Bandits then
    local skillMap = { ["Average"] = "A", ["Good"] = "G", ["High"] = "H", ["Excellent"] = "X" }
    for _, b in ipairs(data.A2A_Bandits) do
      TCS.Catalog.Add({
        id = b.id,
        domain = "AIR",
        mobile = true,
        late_activation = true,
        unit_types = { b.unit_type },
        threat = "AIR_FIGHTER",
        skill_profile = skillMap[b.skill] or "G",
        tags = b.filters,
        data = { payload = b.payload, livery = b.livery }
      })
    end
  end

  -- 3. A2A Packages
  if data.A2A_Packages then
    for _, p in ipairs(data.A2A_Packages) do
      TCS.Catalog.Add({
        id = p.id, domain = "AIR", mobile = true, late_activation = true,
        unit_types = { p.unit_type }, threat = "AIR_SUPPORT",
        tags = { role = p.role }, data = { count = p.count, skill = p.skill }
      })
    end
  end
end

env.info("TCS(CATALOG): ready")