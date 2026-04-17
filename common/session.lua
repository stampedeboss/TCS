---------------------------------------------------------------------
-- TCS COMMON: SESSION
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}

TCS.Common.Session = {}
TCS.Common.Session.__index = TCS.Common.Session

function TCS.Common.Session.New(name, coalition)
    local self = setmetatable({}, TCS.Common.Session)
    self.Name = name
    self.Coalition = coalition or 0
    self.Members = {}
    self.ActiveScenarios = {}
    return self
end

function TCS.Common.Session:Broadcast(text, duration)
    if not text then return end
    for name, _ in pairs(self.Members) do
        local g = GROUP:FindByName(name)
        if g and g:IsAlive() then
            trigger.action.outTextForGroup(g:GetID(), text, duration or 10)
        end
    end
end

env.info("TCS(COMMON.SESSION): ready")