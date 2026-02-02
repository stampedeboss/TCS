
env.info("TCS(A2G.REGISTRY): loading")

TCS = TCS or {}; TCS.A2G = TCS.A2G or {}

TCS.A2G.Registry = {
  bySession = {}
}

function TCS.A2G.Registry:Register(session, object)
  if not session or not object then return end
  local id = session:GetName()
  self.bySession[id] = self.bySession[id] or {}
  table.insert(self.bySession[id], object)
end

function TCS.A2G.Registry:Cleanup(session)
  local id = session:GetName()
  local list = self.bySession[id]
  if not list then return end

  for _, obj in ipairs(list) do
    if obj and obj:IsAlive() then
      obj:Destroy()
    end
  end

  self.bySession[id] = nil
end

env.info("TCS(A2G.REGISTRY): ready")
