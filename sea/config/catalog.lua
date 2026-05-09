---------------------------------------------------------------------
-- TCS SEA TOWER: CATALOG
---------------------------------------------------------------------
env.info("TCS(SEA.CATALOG): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.Catalog = {}

function TCS.Sea.Catalog.Query(params)
    local results = {}
    for _, entry in ipairs(TCS.Sea.Catalog.Data or {}) do
        local match = true
        if params.role and entry.role ~= params.role then match = false end
        if params.tier and entry.tier ~= params.tier then match = false end
        if params.year and entry.years then
            local yearStart = entry.years[1] or 0
            local yearEnd = entry.years[2] or 9999
            if params.year < yearStart or params.year > yearEnd then match = false end
        end
        if match then table.insert(results, entry) end
    end
    return results
end

local function generate_ships()
    local ships = {}
    -- NAVAL: LOGISTICS & CARGO (MAR)
    table.insert(ships, { id="DRYCARGO1", role="CARGO", tier="A", unit_types={"Dry-cargo ship-1"}, skill="Average", years={1960, 9999} })
    table.insert(ships, { id="DRYCARGO2", role="CARGO", tier="A", unit_types={"Dry-cargo ship-2"}, skill="Average", years={1960, 9999} })
    table.insert(ships, { id="HANDYWIND", role="CARGO", tier="A", unit_types={"HandyWind"}, skill="Average", years={2000, 9999} })
    
    -- NAVAL: SURFACE WARFARE (SUW)
    table.insert(ships, { id="SPEEDBOAT", role="PATROL", tier="G", unit_types={"Speedboat"}, skill="Good", years={1980, 9999} })
    table.insert(ships, { id="MOLNIYA", role="CORVETTE", tier="H", unit_types={"Molniya"}, skill="High", years={1979, 9999} })
    table.insert(ships, { id="ALBATROS", role="CORVETTE", tier="H", unit_types={"Albatros"}, skill="High", years={1970, 9999} })
    table.insert(ships, { id="REZKY", role="FRIGATE", tier="X", unit_types={"Rezky"}, skill="Excellent", years={1970, 9999} })
    table.insert(ships, { id="TYPE052C", role="DESTROYER", tier="X", unit_types={"Type_052C"}, skill="Excellent", years={2004, 9999} })
    table.insert(ships, { id="MOSKVA", role="CRUISER", tier="X", unit_types={"Moskva"}, skill="Excellent", years={1982, 9999} })
    table.insert(ships, { id="KUZNETSOV", role="CARRIER", tier="X", unit_types={"Kuznetsov"}, skill="Excellent", years={1991, 9999} })
    table.insert(ships, { id="KILO", role="SUBMARINE", tier="X", unit_types={"Kilo"}, skill="Excellent", years={1980, 9999} })

    return ships
end

TCS.Sea.Catalog.Data = generate_ships()
env.info("TCS(SEA.CATALOG): ready")