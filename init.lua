---------------------------------------------------------------------
-- TCS: THEATER CONTROL SYSTEM - ROOT INITIALIZATION
---------------------------------------------------------------------
env.info("TCS: Initializing Theater Control System...")

TCS = TCS or {}

-- Helper function to load TCS modules dynamically
-- Update this base_path if you move the TCS folder
local base_path = lfs.writedir() .. [[Scripts/TCS/]]

function TCS_LOAD(relative_path)
    local f, err = loadfile(base_path .. relative_path)
    if not f then
        env.error("TCS ERROR: Failed to load module " .. relative_path .. "\n" .. tostring(err))
    else
        f()
        env.info("TCS: Loaded module " .. relative_path)
    end
end

-- 1. Core Common Systems
TCS_LOAD("common/init.lua")

-- 2. Distributed Domain Towers
TCS_LOAD("air/init.lua")
TCS_LOAD("airdef/init.lua")
TCS_LOAD("land/init.lua")
TCS_LOAD("sea/init.lua")
TCS_LOAD("range/init.lua")
TCS_LOAD("deploy/init.lua")
TCS_LOAD("cic/init.lua")

-- 3. Base Systems & API
TCS_LOAD("signals/init.lua")

env.info("TCS: Initialization Complete.")