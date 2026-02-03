---------------------------------------------------------------------
-- menu_builder.lua
-- Central per-player menu wiring
---------------------------------------------------------------------
env.info("TCS(MENU_BUILDER): loading")

TCS = TCS or {}
TCS.Menu = TCS.Menu or {}

function TCS.Menu.BuildForPlayer(rec)
  if not rec or not rec.Group then return end

  if TCS.Menu.BuildRoot then
    TCS.Menu.BuildRoot(rec.Group)
  end

  if TCS.Menu.BuildTraining then
    TCS.Menu.BuildTraining(rec)
  end

  if TCS.Menu.BuildA2A then
    TCS.Menu.BuildA2A(rec)
  end

  if TCS.Menu.BuildA2G then
    TCS.Menu.BuildA2G(rec)
  end

  if TCS.Menu.BuildSUW then
    TCS.Menu.BuildSUW(rec.Group)
  end

  if TCS.Menu.BuildMAR then
    TCS.Menu.BuildMAR(rec.Group)
  end

  if TCS.Menu.BuildAdmin then
    TCS.Menu.BuildAdmin(rec)
  end
end

env.info("TCS(MENU_BUILDER): ready")
