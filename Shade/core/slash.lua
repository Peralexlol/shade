-- File: Shade/core/slash.lua (with theme/modules commands)
-- Self-healing registration + richer commands.

local function handler(msg)
  msg = (msg or ""):lower()
  if msg == "ping" then
    print("|cff8059f2Shade|r: pong (slash alive)")
    return
  elseif msg == "debug" then
    local Shade = _G.Shade
    local hasUI = Shade and Shade.UI ~= nil
    local hasW = hasUI and Shade.UI.Widgets ~= nil
    print("|cff8059f2Shade|r debug:")
    print("  Shade.UI:", hasUI)
    print("  Shade.UI.Widgets:", hasW)
    if hasW and Shade.UI.Widgets.Verify then print("  Widgets version:", Shade.UI.Widgets.Verify()) end
    print("  ToggleConfig:", Shade and type(Shade.ToggleConfig) == "function")
    return
  elseif msg == "ui" or msg == "show" or msg == "hide" then
    if _G.Shade and type(_G.Shade.ToggleConfig) == "function" then _G.Shade.ToggleConfig(msg) else print("|cff8059f2Shade|r: Toggle not ready") end
    return
  end

  -- /shade theme <key>
  if msg:match("^theme ") then
    local key = msg:match("^theme%s+([%w_]+)")
    if _G.Shade and _G.Shade.ThemePresets and _G.Shade.ThemePresets[key] then
      local p = (_G.ShadeDB and _G.ShadeDB.profile) or nil
      if p then p.theme = key end
      if _G.Shade and _G.Shade.applyThemeKey then _G.Shade.applyThemeKey(key) end
      print("|cff8059f2Shade|r: theme set to "..key)
      if _G.Shade and type(_G.Shade.ToggleConfig) == "function" then _G.Shade.ToggleConfig("ui") end
    else
      print("|cff8059f2Shade|r: unknown theme key. Try: flatdark, neon, glass, classtint")
    end
    return
  end

  if _G.Shade and type(_G.Shade.ToggleConfig) == "function" then
    _G.Shade.ToggleConfig()
  else
    print("|cff8059f2Shade|r: Config UI not ready. Check TOC order and file paths.")
  end
end

local function register()
  SLASH_SHADE1 = "/shade"; SLASH_SHADE2 = "/sui"
  SlashCmdList.SHADE = handler
  if not _G.__SHADE_SLASH_PRINTED then
    print("|cff8059f2Shade|r: /shade registered (try '/shade ui')")
    _G.__SHADE_SLASH_PRINTED = true
  end
end

register()

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED"); f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function() register() end)

local elapsed = 0
f:SetScript("OnUpdate", function(self, dt)
  elapsed = elapsed + (dt or 0)
  if elapsed < 5 then
    if type(SlashCmdList.SHADE) ~= "function" then register() end
  else
    self:SetScript("OnUpdate", nil)
  end
end)
