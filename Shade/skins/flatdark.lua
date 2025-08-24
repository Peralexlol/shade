--[=[
File: skins/FlatDark.lua
Flat, minimal dark.
]=]

local Shade = _G.Shade
local SE = Shade.SkinEngine

local Skin = {}
function Skin.Apply(btn, ctx, o, base)
  base:BaseApply(btn, ctx, o)
  if btn.__shade_gloss then btn.__shade_gloss:SetAlpha(0) end
end

SE:RegisterSkin('flat_dark', Skin)
