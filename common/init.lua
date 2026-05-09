-- Make sure sea\config\root.lua was successfully moved here!
-- 1. Core Utilities (Load Logger first!)
TCS_LOAD("common/logger.lua")
TCS_LOAD([[common/defaults.lua]])
TCS_LOAD("common/utils.lua")
TCS_LOAD("common/world.lua")
TCS_LOAD("common/catalog.lua")
TCS_LOAD("common/scenario.lua")
TCS_LOAD("common/tts.lua")

-- 2. Shared UI / Interactivity
--TCS_LOAD("common/menu/root.lua")
--TCS_LOAD("common/menu/admin_builder.lua")
--TCS_LOAD("common/chat/interface.lua")