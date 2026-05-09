---------------------------------------------------------------------
-- TCS TOWER: LOGISTICS
-- Domain Specialist: Convoys, FARPs, and Quick Reaction Forces.
---------------------------------------------------------------------
env.info("TCS(TOWER.LOGISTICS): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Logistics = {}

function TCS.Towers.Logistics.PrepareRequisition(taskCategory, params)
    local manifest = {}
    local side = params.coalition or coalition.side.RED
    local skill = params.skill or "Average"

    if taskCategory == "FARP" then
        table.insert(manifest, {unit_type="Invisible FARP", role="FARP", category="STATIC", isStatic=true, relativePos={x=0, y=0}, skill=skill})
        
        local cmdType  = (side == coalition.side.RED) and "SKP-11" or "M1025 HMMWV"
        local fuelType = (side == coalition.side.RED) and "ATZ-10" or "M978 HEMTT Tanker"
        local ammoType = (side == coalition.side.RED) and "Ural-375" or "M818"
        
        table.insert(manifest, {unit_type=cmdType, role="CP", category="SUPPORT", isStatic=false, relativePos={x=30, y=30}, skill=skill})
        table.insert(manifest, {unit_type=fuelType, role="FUEL", category="SUPPORT", isStatic=false, relativePos={x=-30, y=30}, skill=skill})
        table.insert(manifest, {unit_type=ammoType, role="AMMO", category="SUPPORT", isStatic=false, relativePos={x=30, y=-30}, skill=skill})
        
    elseif taskCategory == "QRF_HELO" then
        local heloType = (side == coalition.side.RED) and "Mi-24P" or "AH-64D_BLK_II"
        for i=1, 2 do
            -- Notice the category is explicitly "HELICOPTER" for CIC to read
            table.insert(manifest, {unit_type=heloType, role="ATTACK", category="HELICOPTER", isStatic=false, relativePos={x=-(i-1)*50, y=(i-1)*50}, skill=skill})
        end
        
    elseif taskCategory == "AIRLIFT" then
        -- Heavy fixed-wing logistics (Extraction / Paradrops)
        local planeType = (side == coalition.side.RED) and "IL-76MD" or "C-130J"
        table.insert(manifest, {unit_type=planeType, role="TRANSPORT", category="AIRPLANE", isStatic=false, relativePos={x=0, y=0}, alt=20000, skill=skill})
    end

    return {
        tower = "LOGISTICS",
        manifest = manifest,
        coalition = side,
        geometry = params.geometry,
        behavior = { mode = (taskCategory == "FARP") and "STATIC" or "ADVANCE", target = params.anchor }
    }
end

env.info("TCS(TOWER.LOGISTICS): ready")