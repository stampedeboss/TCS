---------------------------------------------------------------------
-- TCS CORE: ADMIN (Battlefield Commander)
-- Authority + signaling only. No tasking, no spawning.
---------------------------------------------------------------------
env.info("TCS(ADMIN): loading")

TCS = TCS or {}
TCS.Admin = TCS.Admin or {}

function TCS.Admin.IsAdmin(playerID)
  if not net then return true end
  local admins = (TCS.Config and TCS.Config.System and TCS.Config.System.Admins) or {}
  if #admins == 0 then return true end
  
  local pinfo = net.get_player_info(playerID)
  if not pinfo or not pinfo.ucid then return false end
  for _, ucid in ipairs(admins) do
    if pinfo.ucid == ucid then return true end
  end
  return false
end

---------------------------------------------------------------------
-- Routing (NO domain logic here)
---------------------------------------------------------------------
function TCS.Admin.RouteOrder(order)
  if not order or not order.type then return end

  -- A2G-related conditions
  if order.type == "CAS_OVERRUN"
  or order.type == "IADS_ACTIVE"
  or order.type == "STRIKE_DELAYED" then
    if TCS.A2G and TCS.A2G.OnAdminOrder then
      TCS.A2G.OnAdminOrder(order)
    end
  end

  -- A2A-related conditions
  if order.type == "AIR_SUPERIORITY_THREAT"
  or order.type == "ESCORT_REQUIRED" then
    if TCS.A2A and TCS.A2A.OnAdminOrder then
      TCS.A2A.OnAdminOrder(order)
    end
  end

  -- Maritime (civilian)
  if order.type == "SHIPPING_THREATENED"
  or order.type == "PORT_UNDER_THREAT" then
    if TCS.MAR and TCS.MAR.OnAdminOrder then
      TCS.MAR.OnAdminOrder(order)
    end
  end

  -- Naval combat
  if order.type == "SUW_CONTACT_DETECTED" then
    if TCS.SUW and TCS.SUW.OnAdminOrder then
      TCS.SUW.OnAdminOrder(order)
    end
  end
end

env.info("TCS(ADMIN): ready")
