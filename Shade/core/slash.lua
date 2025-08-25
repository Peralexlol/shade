-- File: Shade/core/slash.lua
-- Purpose: Basic slash commands + theme switch.

local ADDON, Shade = ...

SLASH_SHADE1 = "/shade"; SLASH_SHADE2 = "/sui"
SlashCmdList["SHADE"] = function(msg)
  msg = (msg or ""):lower()
  if msg:match("^theme%s+") then
    local key = msg:gsub("^theme%s+", ""):gsub("%s+", "")
    if Shade:ApplyTheme(key) then
      print("Shade:", "theme set to", key)
    else
      print("Shade:", "unknown theme. Available:")
      for k, th in pairs(Shade.const.themes) do print(" -", k, th.name or k) end
    end
    return
  end
  if msg == "ui" or msg == "show" then if Shade.UI and Shade.UI.Show then Shade.UI:Show() end return end
  if msg == "hide" then if Shade.UI and Shade.UI.Hide then Shade.UI:Hide() end return end
  if msg == "ping" then print("pong") return end
  print("Shade commands:", "/shade theme <key>", "/shade ui|show|hide", "/shade ping")
end
