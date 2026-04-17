---------------------------------------------------------------------
-- TCS TEST SUITE: RANGES
-- Validates the Range Architect, polymorphic layouts, and Direct APIs.
---------------------------------------------------------------------
env.info("TCS(TEST): Loading Range Test Suite...")

function Test_ALL_RANGES()
    env.info("TCS(TEST): ===================================================")
    env.info("TCS(TEST): Running Full Range Architect Test Suite...")
    env.info("TCS(TEST): ===================================================")

    -- Use the first available airbase as the master anchor so it works on any map
    local refBase = AIRBASE:GetAllAirbases()[1]
    if not refBase then
        env.error("TCS(TEST): No airbases found on this map to use as a test anchor.")
        return
    end
    
    local baseCoord = refBase:GetCoordinate()
    env.info("TCS(TEST): Master Anchor set to " .. refBase:GetName())

    -- Test 1: Bombing Range (FAST_JET)
    -- Expect: 5 static containers in a cross pattern.
    local c1 = baseCoord:Translate(10 * 1852, 0)
    TriggerSystemBomb({
        anchor = c1,
        equipmentType = "FA-18C_hornet",
        minNm = 1,
        maxNm = 2,
        ingressHdg = 45,
        duration = 3600
    })

    -- Test 2: Strafe Range (HELO)
    -- Expect: Cluster of infantry and a FARP 2NM behind them.
    local c2 = baseCoord:Translate(10 * 1852, 45)
    TriggerSystemStrafe({
        anchor = c2,
        equipmentType = "AH-64D_BLK_II",
        minNm = 1,
        maxNm = 2,
        ingressHdg = 90,
        duration = 3600
    })

    -- Test 3: Mixed Range (DEFAULT / Subsonic)
    -- Expect: Bunker, T-72, Ural, Shilka, Container in a 300m footprint.
    local c3 = baseCoord:Translate(10 * 1852, 90)
    TriggerSystemMixed({
        anchor = c3,
        equipmentType = "A-10C_2",
        minNm = 1,
        maxNm = 2,
        ingressHdg = 135,
        duration = 3600
    })

    -- Test 4: Convoy (FAST_JET)
    -- Expect: 4 Ural-375s moving at 40kph along the ingress heading.
    local c4 = baseCoord:Translate(10 * 1852, 135)
    TriggerSystemConvoy({
        anchor = c4,
        equipmentType = "FA-18C_hornet",
        minNm = 2,
        maxNm = 3,
        ingressHdg = 180,
        speedKph = 40,
        duration = 3600
    })

    -- Test 5: Moving Armor (HELO)
    -- Expect: Staggered formation of T-72s and BMPs moving at 25kph, plus a FARP.
    local c5 = baseCoord:Translate(10 * 1852, 180)
    TriggerSystemMovingArmor({
        anchor = c5,
        equipmentType = "AH-64D_BLK_II",
        minNm = 2,
        maxNm = 3,
        ingressHdg = 225,
        speedKph = 25,
        duration = 3600
    })

    -- Test 6: Radar Emitter (FAST_JET)
    -- Expect: P-19 Search Radar. Alarm State RED, ROE WEAPON_HOLD.
    local c6 = baseCoord:Translate(10 * 1852, 225)
    TriggerSystemRadarEmitter({
        anchor = c6,
        equipmentType = "FA-18C_hornet",
        minNm = 1,
        maxNm = 2,
        ingressHdg = 270,
        duration = 3600
    })

    env.info("TCS(TEST): Range Test Suite execution complete. Check F10 map.")
end

env.info("TCS(TEST): Range Test Suite Ready. Use 'Test_ALL_RANGES()' in console.")