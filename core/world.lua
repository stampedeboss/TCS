
env.info("TCS(WORLD): loading")
TCS = TCS or {}
TCS.World = { Objects = {} }

local function _id()
  return tostring(timer.getAbsTime()) .. "_" .. math.random(1000,9999)
end

function TCS.World.Register(obj)
  obj.id = obj.id or _id()
  TCS.World.Objects[obj.id] = obj
  return obj.id
end

function TCS.World.Remove(id)
  TCS.World.Objects[id] = nil
end

env.info("TCS(WORLD): ready")
