--[=[
File: skins/ClassTint.lua
Dark base + class-colored border/glow.
]=]

local Shade = _G.Shade
local SE = Shade.SkinEngine

local function classColor()
  local _, class = UnitClass('player')
  local c = RAID_CLASS_COLORS[class] or { r=.8,g=.8,b=.8 }
  return c.r, c.g, c.b
end

local Skin = {}
function Skin.Apply(btn, ctx, o, base)
  base:BaseApply(btn, ctx, o)
  local r,g,b = classColor()
  if not btn.__shade_class then
    local n = btn:CreateTexture(nil, 'OVERLAY')
    n:SetPoint('TOPLEFT', -1, 1); n:SetPoint('BOTTOMRIGHT', 1, -1)
    n:SetTexture('Interface/Buttons/WHITE8x8'); btn.__shade_class = n
  end
  btn.__shade_class:SetColorTexture(r,g,b,0.25)
end

SE:RegisterSkin('class_tint', Skin)
