---------------------------------------------------------------------
-- TCS COMMON: SESSION MANAGER
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.SessionManager = { Sessions = {} }

function TCS.Common.SessionManager:GetOrCreateSessionForGroup(group)
    if not group then return self:Ensure("SYSTEM") end
    local name = group:GetName()
    if not self.Sessions[name] then
        self.Sessions[name] = TCS.Common.Session.New(name, group:GetCoalition())
        self.Sessions[name].Members[name] = true
    end
    return self.Sessions[name]
end

function TCS.Common.SessionManager:Ensure(name)
    if not self.Sessions[name] then
        self.Sessions[name] = TCS.Common.Session.New(name, 0)
    end
    return self.Sessions[name]
end

function TCS.Common.SessionManager:GetSessionForGroup(group)
    if not group then return nil end
    return self.Sessions[group:GetName()]
end

env.info("TCS(COMMON.SESSION_MANAGER): ready")