---------------------------------------------------------------------
-- TCS LOGISTICS: FARP OPERATIONS
-- Handles the dynamic deployment of forward arming and refueling points.
---------------------------------------------------------------------
env.info("TCS(LOGISTICS.FARP): loading")

TCS = TCS or {}
TCS.Logistics = TCS.Logistics or {}

--- Deploys an invisible FARP and its required support vehicles.
-- @param coord The map coordinate {x, y, z} to spawn the FARP at.
-- @param heading The heading in radians.
-- @param side The coalition side (e.g., coalition.side.BLUE).
-- @param playerName (Optional) Used to uniquely tag the FARP name.
function TCS.Logistics.SpawnFARP(coord, heading, side, playerName)
    if not coord then return false end
    heading = heading or 0
    side = side or coalition.side.BLUE
    
    local farpName = "TCS_DYN_FARP_" .. math.random(100000, 999999)
    if playerName then farpName = farpName .. "_" .. string.gsub(playerName, "[%p%c%s]", "") end
    
    local farpData = { type = "Invisible FARP", name = farpName, x = coord.x, y = coord.z, heading = heading, category = "Heliports" }
    
    if TCS.Spawn and TCS.Spawn.StaticFromData then
       TCS.Spawn.StaticFromData(farpData, side)
       
       -- Support Assets
       local supportName = farpName .. "_SUP"
       local offX = coord.x + 30 * math.cos(heading)
       local offY = coord.z + 30 * math.sin(heading)
       
       local fuel = (side == coalition.side.RED) and "ATMZ-5" or "M978 HEMTT Tanker"
       local ammo = (side == coalition.side.RED) and "Ural-375" or "M818"
       local cmdType  = (side == coalition.side.RED) and "SKP-11" or "M1025 HMMWV"
       local pwrType  = (side == coalition.side.RED) and "APA-5D" or "M1025 HMMWV"
       
       local groupData = {
         name = supportName, task = "Ground Nothing",
         units = {
           [1] = { name=supportName.."_1", type=cmdType, x=offX, y=offY, heading=heading, skill="High" },
           [2] = { name=supportName.."_2", type=ammo, x=offX+8, y=offY+8, heading=heading, skill="High" },
           [3] = { name=supportName.."_3", type=fuel, x=offX-8, y=offY+8, heading=heading, skill="High" },
           [4] = { name=supportName.."_4", type=pwrType, x=offX, y=offY+15, heading=heading, skill="High" },
         }
       }
       
       TCS.Spawn.GroupFromData(groupData, Group.Category.GROUND, side)
       local _gp = Group.getByName(supportName)
       if _gp then _gp:getController():setCommand({id = 'SetImmortal', params = {value = true}}) end
       
       env.info("TCS(LOGISTICS): FARP spawned at " .. farpName)
       return farpName
    else
        env.error("TCS(LOGISTICS): Legacy TCS.Spawn not found for FARP generation.")
        return false
    end
end

env.info("TCS(LOGISTICS.FARP): ready")