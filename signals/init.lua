---------------------------------------------------------------------
-- TCS SIGNALS INITIALIZATION
---------------------------------------------------------------------
env.info("TCS(SIGNALS): Bootstrapping Signals Domain...")

TCS_LOAD("signals/config.lua")
TCS_LOAD("signals/f10_map.lua")
TCS_LOAD("signals/admin.lua")
TCS_LOAD("signals/chat_commands.lua")
TCS_LOAD("signals/theater_api.lua")