
---------------------------------------------------------------------
-- TCS A2G – CAS (Close Air Support)
---------------------------------------------------------------------

env.info("TCS(A2G.CAS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}

local TAG = "CAS"

local function destroyExistingCAS(session)
  TCS.A2G.Registry:CleanupByTag(session, TAG)
end

function TCS.A2G.CAS(group, opts)
  if not group then return end
  opts = opts or {}

  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then
    TCS.A2G.Feedback.Group(group, "Unable to create operational session")
    return
  end

  destroyExistingCAS(session)
  TCS.A2G.Feedback.Group(group, "Replacing existing CAS tasking")

  local anchor, reason = TCS.Placement.Resolve(group:GetUnit(1))
  if not anchor then
    TCS.A2G.Feedback.Group(group, "Unable to establish CAS battlespace", reason)
    return
  end

  -- Store target for JTAC operations (Laser On)
  session.A2G_Target = anchor

  local friendlyEch = opts.echelon or TCS.SessionScale:GetEchelon(session)
  local enemyEch    = TCS.SessionScale:BalanceOpposition(friendlyEch)

  if not enemyEch then
    TCS.A2G.Feedback.Group(group, "Unable to establish CAS battlespace", "force balance failed")
    return
  end

  local friendly = TCS.A2G.ForceSpawner.Spawn(session, "MECH_INF", friendlyEch, anchor, {coalition=coalition.side.BLUE})
  local enemy    = TCS.A2G.ForceSpawner.Spawn(session, "MECH_INF", enemyEch, anchor, {coalition=coalition.side.RED})

  if not friendly or not enemy then
    TCS.A2G.Feedback.Group(group, "Unable to establish CAS battlespace", "spawn failure")
    return
  end

  if TCS.A2G.JTAC and TCS.A2G.JTAC.MarkFriendlies then
    TCS.A2G.JTAC.MarkFriendlies(session, friendly)
  end

  if TCS.A2G.JTAC and TCS.A2G.JTAC.BriefCAS then
    TCS.A2G.JTAC.BriefCAS(session, anchor)
  end

  TCS.A2G.Feedback.Group(group, "CAS support established")
end

env.info("TCS(A2G.CAS): ready")
