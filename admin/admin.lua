---------------------------------------------------------------------
-- TCS CORE: ADMIN (Battlefield Commander)
-- Authority + signaling only. No tasking, no spawning.
---------------------------------------------------------------------
env.info("TCS(ADMIN): loading")

TCS = TCS or {}
TCS.Admin = TCS.Admin or {}

---------------------------------------------------------------------
-- Order structure (example)
-- {
--   type      = "CAS_OVERRUN",
--   location  = <coord>,
--   priority  = "HIGH",
--   metadata  = {}
-- }
---------------------------------------------------------------------

-- Issue an order from a commander
function TCS.Admin.IssueOrder(order)
  if not order or not order.type then
    env.warning("TCS(ADMIN): invalid order")
    return
  end

  env.info("TCS(ADMIN): order issued: " .. tostring(order.type))

  -- Broadcast intent to relevant domains
  TCS.Admin.RouteOrder(order)
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
