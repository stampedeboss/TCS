---------------------------------------------------------------------
-- TCS DIAGNOSTIC: AIR CATALOG TESTER
-- Dumps all generated combinations from the unified catalog
---------------------------------------------------------------------

-- Mock env.info if running outside of DCS
local log = env and env.info or print

log("TCS(TEST): Running Air Catalog Generation Test...")

-- Ensure the catalog is loaded
if not TCS or not TCS.Air or not TCS.Air.Catalog or not TCS.Air.Catalog.Data then
    log("TCS(TEST): ERROR - TCS.Air.Catalog.Data table not found. Ensure catalog.lua is loaded first.")
    return
end

local catalog = TCS.Air.Catalog.Data
local totalCount = 0

local roles = {}
local tiers = {}
local types = {}

log(string.format("=== TCS Air Catalog Test ==="))

for section, sectionData in pairs(catalog) do
    log(string.format("\n--- SECTION: %s ---", section))
    for i, aircraft in ipairs(sectionData) do
        totalCount = totalCount + 1
        local f = aircraft.filters or {}
        
        local role = f.role or aircraft.role or "N/A"
        local tier = f.tier or "N/A"
        local btype = aircraft.unit_types and aircraft.unit_types[1] or aircraft.type or "N/A"
        
        roles[role] = (roles[role] or 0) + 1
        tiers[tier] = (tiers[tier] or 0) + 1
        types[btype] = (types[btype] or 0) + 1
        
        local payload_count = 0
        if aircraft.data and aircraft.data.payload and aircraft.data.payload.pylons then
            for k, v in pairs(aircraft.data.payload.pylons) do payload_count = payload_count + 1 end
        end
        
        log(string.format("[%03d] ID: %-30s | Type: %-15s | Role: %-8s | Tier: %-3s | Skill: %-10s | Pylons Loaded: %d", 
            totalCount, aircraft.id, btype, role, tier, aircraft.skill or "N/A", payload_count))
    end
end

log("\n--- Summary by Role ---")
for r, c in pairs(roles) do log(string.format("%-14s : %d", r, c)) end

log("\n--- Summary by Tier ---")
for t, c in pairs(tiers) do log(string.format("%-14s : %d", t, c)) end

log("\n--- Summary by Type ---")
for t, c in pairs(types) do log(string.format("%-15s : %d", t, c)) end

log(string.format("\nTotal unique combinations generated: %d", totalCount))