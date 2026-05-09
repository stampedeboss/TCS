---------------------------------------------------------------------
-- TCS ADMIN TOWER: MENU BUILDER
-- Injects Admin cleanup options into the Common Menu Root.
---------------------------------------------------------------------
env.info("TCS(ADMIN.MENU_BUILDER): loading")

TCS = TCS or {}
TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}

table.insert(TCS.Menu.Builders, function(client, roots)
    if not roots.Admin then return end
    
    -- Optional: Check if player is an Admin before building these menus
    -- if TCS.CIC and TCS.CIC.Admin and TCS.CIC.Admin.IsAdmin then
    --     local pID = client:GetPlayerID()
    --     if not TCS.CIC.Admin.IsAdmin(pID) then return end
    -- end

    MENU_CLIENT_COMMAND:New(client, "Reset All Menus", roots.Admin, function()
        if TCS.Menu.ClientSet then
            TCS.Menu.ClientSet:ForEachClient(function(c)
                if TCS.Menu.BuildRoot then TCS.Menu.BuildRoot(c) end
            end)
            if MESSAGE then MESSAGE:New("TCS ADMIN: All F10 Menus have been reset.", 10):ToClient(client) end
        end
    end)

    MENU_CLIENT_COMMAND:New(client, "Cleanup All Spawns", roots.Admin, function()
        -- Prefix list covers both new V2 spawns ("TCS-") and legacy spawns
        local prefixes = { "TCS-", "BANDIT", "CAS", "BAI", "SAM", "STRIKE", "MAR", "SUW", "QRF" }
        local count = 0
        
        local function cleanCat(cat)
            for _, side in pairs({coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL}) do
                local groups = coalition.getGroups(side, cat) or {}
                for _, g in ipairs(groups) do
                    local name = g:getName()
                    for _, p in ipairs(prefixes) do
                        if string.find(name, "^" .. p) then
                            g:destroy()
                            count = count + 1
                            break
                        end
                    end
                end
            end
        end

        cleanCat(Group.Category.AIRPLANE)
        cleanCat(Group.Category.HELICOPTER)
        cleanCat(Group.Category.GROUND)
        cleanCat(Group.Category.SHIP)

        if MESSAGE then MESSAGE:New("TCS ADMIN: Theater Cleanup complete. Removed " .. count .. " groups.", 10):ToClient(client) end
    end)
end)

env.info("TCS(ADMIN.MENU_BUILDER): ready")
