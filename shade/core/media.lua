-- File: shade/core/media.lua
-- Handles addon media (fonts, textures) and provides font objects.

local Shade = _G.Shade
Shade.Media = Shade.Media or {}

-- Font path (user provided Oxanium.ttf inside media/)
local FONT_PATH = "Interface\\AddOns\\shade\\media\\Oxanium.ttf"
Shade.Media.FONT_PATH = FONT_PATH

-- Cache of dynamically created font objects by size+flags
local cache = {}

--- Returns a WoW FontObject using the Shade font at given size/flags.
-- @param size number
-- @param flags string (e.g., "OUTLINE")
-- @return FontObject
function Shade:GetFont(size, flags)
  size = tonumber(size) or 12
  flags = flags or ""
  local key = size .. "|" .. flags
  if cache[key] and cache[key].GetFont and select(1, cache[key]:GetFont()) then
    return cache[key]
  end
  local obj = CreateFont("ShadeFont_" .. key)
  obj:SetFont(FONT_PATH, size, flags)
  obj:SetSpacing(0)
  obj:SetShadowColor(0, 0, 0, 0.6)
  obj:SetShadowOffset(0.5, -0.5)
  cache[key] = obj
  return obj
end
