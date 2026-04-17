env.info("TCS(MSI): loading")

-- 1. Resolve Script Path
local MSI_PATH = lfs.writedir() .. [[Missions\Scripts\DCS\TCS\MSI\]]
env.info("MSI(INIT): Path set to " .. MSI_PATH)

local function load_msi(file)
  local p = MSI_PATH .. file
  env.info("MSI(INIT): Loading " .. p)
  local f, err = loadfile(p)
  if not f then
    env.error("MSI(INIT): Failed to load " .. p .. ": " .. tostring(err))
  else
    local status, result = pcall(f)
    if not status then
      env.error("MSI(INIT): Error executing " .. p .. ": " .. tostring(result))
    end
  end
end

TCS = TCS or {}
TCS.MSI = {} -- Create the namespace for the MSI module

-- 3. Load Maps & Defenses
-- Note: Maps check env.mission.theatre internally, so safe to load all
load_msi("caucasus.lua")
load_msi("syria.lua")
load_msi("mariana.lua")
load_msi("persiangulf.lua")
load_msi("kola.lua")
load_msi("nevada.lua")
load_msi("caucasus_defenses.lua")

env.info("TCS(MSI): ready")