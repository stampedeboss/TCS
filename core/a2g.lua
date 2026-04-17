---------------------------------------------------------------------
-- TCS DISPATCH: A2G
-- Streamlined entry points for ME triggers and quick-scripting.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
env.info("TCS(DISPATCH.A2G): loading")

TCS = TCS or {}
TCS.Dispatch = TCS.Dispatch or {}
TCS.Dispatch.A2G = {}

local function _isTable(val) return type(val) == "table" and not val.GetVec3 end

--- Streamlined BAI Interface
function TCS.Dispatch.A2G.BAI(anchor, echelon, minNm, maxNm, coalitionSide, respawn, duration, respawnDelay, reinforce, skill, ingressHdg, ingressArc)
    if _isTable(anchor) then
        local p = anchor
        return TCS.Dispatch.A2G.BAI(p.anchor, p.echelon, p.minNm, p.maxNm, p.coalition, p.respawn, p.duration, p.respawnDelay, p.reinforce, p.skill, p.ingressHdg, p.ingressArc)
    end

    local params = {
        anchor = anchor, echelon = echelon or "COMPANY",
        minNm = minNm, maxNm = maxNm, coalition = coalitionSide or coalition.side.RED,
        respawn = respawn, duration = duration, respawnDelay = respawnDelay,
        reinforce = (reinforce ~= false), skill = skill,
        ingressHdg = ingressHdg, ingressArc = ingressArc,
        group = nil
    }
    return TCS.Rules.A2G.DispatchBAI(params)
end

--- Streamlined Strike Interface
function TCS.Dispatch.A2G.Strike(anchor, echelon, minNm, maxNm, coalitionSide, respawn, duration, respawnDelay, skill, ingressHdg, ingressArc)
    if _isTable(anchor) then
        local p = anchor
        return TCS.Dispatch.A2G.Strike(p.anchor, p.echelon, p.minNm, p.maxNm, p.coalition, p.respawn, p.duration, p.respawnDelay, p.skill, p.ingressHdg, p.ingressArc)
    end

    local params = {
        anchor = anchor, echelon = echelon or "BATTALION",
        minNm = minNm, maxNm = maxNm, coalition = coalitionSide or coalition.side.RED,
        respawn = respawn, duration = duration, respawnDelay = respawnDelay,
        skill = skill, ingressHdg = ingressHdg, ingressArc = ingressArc,
        group = nil
    }
    return TCS.Rules.A2G.DispatchStrike(params)
end

--- Streamlined SEAD/DEAD Interface
function TCS.Dispatch.A2G.SEAD(anchor, echelon, minNm, maxNm, coalitionSide, respawn, duration, respawnDelay, skill, ingressHdg, ingressArc)
    if _isTable(anchor) then
        local p = anchor
        return TCS.Dispatch.A2G.SEAD(p.anchor, p.echelon, p.minNm, p.maxNm, p.coalition, p.respawn, p.duration, p.respawnDelay, p.skill, p.ingressHdg, p.ingressArc)
    end

    local params = {
        anchor = anchor, echelon = echelon or "PLATOON",
        minNm = minNm, maxNm = maxNm, coalition = coalitionSide or coalition.side.RED,
        respawn = respawn, duration = duration, respawnDelay = respawnDelay,
        skill = skill, ingressHdg = ingressHdg, ingressArc = ingressArc,
        group = nil
    }
    return TCS.Rules.A2G.DispatchSEAD(params)
end

--- Streamlined CAS Interface
function TCS.Dispatch.A2G.CAS(anchor, echelon, playerSide, respawn, duration, respawnDelay, skill, ingressHdg, ingressArc)
    if _isTable(anchor) then
        local p = anchor
        return TCS.Dispatch.A2G.CAS(p.anchor, p.echelon, p.playerSide, p.respawn, p.duration, p.respawnDelay, p.skill, p.ingressHdg, p.ingressArc)
    end

    local params = {
        anchor = anchor, echelon = echelon or "COMPANY",
        playerSide = playerSide or coalition.side.BLUE,
        respawn = respawn, duration = duration, respawnDelay = respawnDelay,
        skill = skill, ingressHdg = ingressHdg, ingressArc = ingressArc,
        group = nil
    }
    return TCS.Rules.A2G.DispatchCAS(params)
end

env.info("TCS(DISPATCH.A2G): ready")
