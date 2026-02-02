---------------------------------------------------------------------
-- menu_builder.lua
-- Central per-player menu wiring
---------------------------------------------------------------------
env.info("TCS(MENU_BUILDER): loading")

TCS_MENU = TCS_MENU or {}

function TCS_MENU.BuildForPlayer(rec)
  if not rec or not rec.Group then return end

  if TCS_MENU.BuildRoot then
    TCS_MENU.BuildRoot(rec.Group)
  end

  if TCS_MENU.BuildTraining then
    TCS_MENU.BuildTraining(rec)
  end

  if TCS_MENU.BuildA2A then
    TCS_MENU.BuildA2A(rec)
  end

  if TCS_MENU.BuildA2G then
    TCS_MENU.BuildA2G(rec)
  end

  if TCS_MENU.BuildAdmin then
    TCS_MENU.BuildAdmin(rec)
  end
end

env.info("TCS(MENU_BUILDER): ready")
