-- tcs_a2g_dynamic_spawn.lua
-- =========================================================
-- TCS Dynamic A2G Range Builder
-- Uses MOOSE RANGE + FunkMan
-- =========================================================

TCS = TCS or {}
TCS.RANGE = TCS.RANGE or {}

-- Entry point called from existing F10 menus
function TCS.RANGE:CreateDynamic(session, rangeKey)
  if not session or not session.owner then return end

  local cfg = TCS.RANGE_CONFIG[rangeKey]
  if not cfg then return end

  local ownerUnit = Unit.getByName(session.owner)
  if not ownerUnit then return end

  local center = ownerUnit:getPoint()
  local hdg = ownerUnit:getHeading()

  local statics = {}
  local coords = TCS.RANGE:BuildPattern(cfg.pattern, center, hdg, cfg)

  for i, pos in ipairs(coords) do
    local staticType = cfg.target_pool[math.random(#cfg.target_pool)]
    local name = string.format("%s_%s_%02d", session.name, rangeKey, i)

    local s = coalition.addStaticObject(session.coalition, {
      category = StaticObject.Category.STRUCTURE,
      type = staticType,
      name = name,
      x = pos.x,
      y = pos.z,
      heading = hdg
    })

    if s then table.insert(statics, name) end
  end

  local range = RANGE:New(session.name .. "_" .. rangeKey)

  for _, name in ipairs(statics) do
    if cfg.purpose == "BOMB" or cfg.purpose == "MIXED" then
      range:AddBombingTarget(name)
    end
    if cfg.purpose == "STRAFE" or cfg.purpose == "MIXED" then
      range:AddStrafePit(name, cfg.strafe_length or 200)
    end
  end

  range:SetFunkManOn()
  range:Start()

  session.range = range
  session.rangeStatics = statics

  env.info("#################### TCS RANGE CREATED ####################")
end

-- Cleanup when session ends
function TCS.RANGE:Destroy(session)
  if not session then return end

  if session.range then
    session.range:Stop()
    session.range = nil
  end

  if session.rangeStatics then
    for _, name in ipairs(session.rangeStatics) do
      local s = StaticObject.getByName(name)
      if s then s:destroy() end
    end
    session.rangeStatics = nil
  end
end
