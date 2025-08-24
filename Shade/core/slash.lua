-- File: Shade/core/Slash.lua
-- Purpose: Robust slash registration decoupled from UI build

local addonName = ... or "Shade"

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

local function Toggle()
  if type(Shade.ToggleConfig) == "function" then
    Shade.ToggleConfig()
  else
    print("|cff8059f2Shade|r: Config UI not ready. Check TOC order and that ui/Widgets.lua + ui/ConfigUI.lua exist.")
  end
end

local function DebugInfo()
  local hasUI = Shade.UI ~= nil
  local hasW = hasUI and Shade.UI.Widgets ~= nil
  print("|cff8059f2Shade|r debug:")
  print("  Shade.UI:", hasUI)
  print("  Shade.UI.Widgets:", hasW)
  if hasW and Shade.UI.Widgets.Verify then
    print("  Widgets version:", Shade.UI.Widgets.Verify())
  end
  print("  ToggleConfig:", type(Shade.ToggleConfig) == "function")
end

SLASH_SHADE1 = "/shade"
SLASH_SHADE2 = "/sui"
SlashCmdList.SHADE = function(msg)
  msg = (msg or ""):lower()
  if msg == "debug" then
    DebugInfo()
  else
    Toggle()
  end
end
