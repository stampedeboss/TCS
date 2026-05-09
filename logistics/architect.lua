---------------------------------------------------------------------
-- TCS LOGISTICS ARCHITECT
-- Director Layer: Assembles Sustainment and Recovery requisitions.
---------------------------------------------------------------------
env.info("TCS(LOGISTICS.ARCHITECT): loading")

TCS = TCS or {}
TCS.Logistics = TCS.Logistics or {}
TCS.Logistics.Architect = {}

function TCS.Logistics.Architect.Build(missionType, params)
    local anchor = params.anchor
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        anchor = z and z:GetCoordinate() or nil
    elseif type(anchor) == "table" and anchor.GetCoordinate then
        anchor = anchor:GetCoordinate()
    end
    if not anchor then return nil end
    params.coalition = params.coalition or coalition.side.RED
    params.anchor = anchor
    local envSpec = { missionType = missionType, anchor = anchor, components = {}, successCriteria = {} }

    if missionType == "BUILD_FARP" then
        table.insert(envSpec.components, TCS.Towers.Logistics.PrepareRequisition("FARP", params))
        -- Sub-contract AirDef for point defense
        table.insert(envSpec.components, TCS.Towers.AirDef.PrepareRequisition("SHORAD", {anchor=anchor, coalition=params.coalition}))
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.8, result = "FARP_DESTROYED" } }
    elseif missionType == "DISPATCH_QRF" then
        table.insert(envSpec.components, TCS.Towers.Logistics.PrepareRequisition("QRF_HELO", params))
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 1.0, result = "QRF_DEFEATED" } }
    else return nil end

    local spawnDist = math.random((params.minNm or 0) * 1852, (params.maxNm or 0) * 1852)
    if missionType == "DISPATCH_QRF" then spawnDist = math.random(15 * 1852, 25 * 1852) end
    local hdgRad = params.ingressHdg and math.rad(params.ingressHdg) or (math.random(0, 359) * math.pi / 180)
    local deployCenter = anchor:Translate(spawnDist, hdgRad)

    for _, comp in ipairs(envSpec.components) do
        if comp.manifest then
            for _, item in ipairs(comp.manifest) do
                local rel = item.relativePos or {x=0, y=0}
                local absCoord = deployCenter:Translate(rel.x * math.cos(hdgRad) - rel.y * math.sin(hdgRad), 0):Translate(rel.x * math.sin(hdgRad) + rel.y * math.cos(hdgRad), math.pi/2)
                item.pos = { x = absCoord.x, y = absCoord.z }; item.heading = hdgRad
            end
        end
    end
    if TCS.CIC and TCS.CIC.Spawner and TCS.CIC.Spawner.Execute then return TCS.CIC.Spawner.Execute(envSpec) end
    return envSpec
end
env.info("TCS(LOGISTICS.ARCHITECT): ready")