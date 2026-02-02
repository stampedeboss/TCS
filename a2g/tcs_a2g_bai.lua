
---------------------------------------------------------------------
-- TCS A2G – BAI (Battlefield Air Interdiction)
--
-- Purpose:
--   Establish and manage a BAI battlespace owned by the pilot session.
--
-- Key Properties:
--   • Requires a session (implicit creation allowed)
--   • Replaces any existing BAI tasking for the session
--   • Uses shared placement, bias, spacing, and force composition
--   • Mandatory A2G AWACS directional tasking
--   • Verbose failure reporting
--
-- Ownership:
--   All spawned objects are registered to the session and cleaned up
--   deterministically on replacement, session end, or reassignment.
---------------------------------------------------------------------

env.info("TCS(A2G.BAI): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}

local TAG = "BAI"

---------------------------------------------------------------------
-- Helper: Destroy existing BAI assets for session
---------------------------------------------------------------------
local function DestroyExistingBAI(session)
  if not TCS.A2G.Registry then return end
  TCS.A2G.Registry:CleanupByTag(session, TAG)
end

---------------------------------------------------------------------
-- Entry Point
---------------------------------------------------------------------
function TCS.A2G.BAI(group, opts)
  if not group then return end
  opts = opts or {}

  -- Resolve or create session
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then
    MESSAGE:New("TCS: Unable to create operational session", 10):ToGroup(group)
    return
  end

  -- Replace semantics
  DestroyExistingBAI(session)
  MESSAGE:New("TCS: Replacing existing BAI tasking", 8):ToGroup(group)

  -- Resolve echelon (selectable)
  local echelon = opts.echelon or TCS.SessionScale:GetEchelon(session)

  -- Placement
  local anchor, reason = TCS.A2G.Placement.Resolve(session)
  if not anchor then
    MESSAGE:New(
      "TCS: Unable to establish BAI battlespace\nReason: " .. (reason or "unknown"),
      12
    ):ToGroup(group)
    return
  end

  -- Bias placement for BAI
  anchor = TCS.A2G.PlacementBias.Resolve(anchor, TAG)

  -- Spawn force
  local spawned = TCS.A2G.ForceSpawner:Spawn(session, TAG, echelon, anchor)
  if not spawned or #spawned == 0 then
    MESSAGE:New(
      "TCS: BAI force generation failed",
      12
    ):ToGroup(group)
    return
  end

  -- Register ownership
  for _, obj in ipairs(spawned) do
    TCS.A2G.Registry:Register(session, obj, TAG)
  end

  -- Mandatory A2G AWACS tasking
  if TCS.A2G.AWACS then
    TCS.A2G.AWACS:AssignBAI(group, anchor, echelon)
  end

  MESSAGE:New("TCS: BAI battlespace established", 10):ToGroup(group)
end

env.info("TCS(A2G.BAI): ready")
