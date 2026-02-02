-- TCS_a2g/a2g_config.lua
A2G_CFG = {
  -- Common behavior
  LEAD_ONLY_STARTS = true,

  -- Spawn distances are relative to the session lead by default
  DEFAULT_SPAWN_MIN_NM = 25,
  DEFAULT_SPAWN_MAX_NM = 45,


  -- Skill range behavior
  SKILL_RANGE_DISTANCE_NM = 15,
  SKILL_RANGE_WARNINGS_ONLY = true,

  -- Template naming conventions (Mission Editor groups, Late Activation)
    TEMPLATES = {
    -- JTAC / FAC
    JTAC = "JTAC",


    -- Skill Range templates (Late Activated ground groups)
    RANGE_CIRCLE = "A2G_RANGE_CIRCLE",
    RANGE_ROW    = "A2G_RANGE_ROW",
    RANGE_STRAFE = "A2G_RANGE_STRAFE",
    RANGE_MISC   = "A2G_RANGE_MISC",

    -- CAS templates (Late Activated ground groups)
    -- Enemy (RED):  "CAS RED-1", "CAS RED-2", ...
    -- Friendlies (BLUE): "CAS BLUE-1", "CAS BLUE-2", ...
    CAS_RED_PREFIX   = "CAS RED-",
    CAS_BLUE_PREFIX  = "CAS BLUE-",

    -- Other categories (placeholders; name similarly later if desired)
    BAI_TARGET_PREFIX    = "BAI TARGET-",
    SAM_SITE_PREFIX      = "SAM SITE-",
    STRIKE_TARGET_PREFIX = "STRIKE TARGET-",
    MAR_SHIP_PREFIX      = "MAR-",
    SUW_GROUP_PREFIX     = "SUW-",
  },

}
