---------------------------------------------------------------------
-- TCS COMMON CATALOG REGISTRY
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Catalog = { Entries = {} } -- Initialize Entries table

function TCS.Common.Catalog.Add(entry)
  if not entry.id then env.error("TCS(CATALOG): Entry missing ID") return end
  table.insert(TCS.Common.Catalog.Entries, entry) -- Add to the Entries table
end

function TCS.Common.Catalog.Query(filter)
  local results = {}
  for _, entry in ipairs(TCS.Common.Catalog.Entries) do
    local match = true
    if filter then
      for k, v in pairs(filter) do
        local val = entry[k] or (entry.tags and entry.tags[k])
        if val ~= v then match = false; break end
      end
    end
    if match then table.insert(results, entry) end
  end
  return results
end

env.info("TCS(COMMON.CATALOG): ready")