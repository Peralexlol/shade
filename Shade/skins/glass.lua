--[=[
File: skins/Glass.lua
Subtle glass with soft gloss.
]=]

local Shade = _G.Shade
local SE = Shade.SkinEngine

local Skin = {}
function Skin.Apply(btn, ctx, o, base)
  o = o or {}
  o.gloss = o.gloss or 0.25
  base:BaseApply(btn, ctx, o)
end

SE:RegisterSkin('glass', Skin)
