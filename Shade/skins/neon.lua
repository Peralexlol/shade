--[=[
File: skins/Neon.lua
Dark base with neon outline glow.
]=]

local Shade = _G.Shade
local SE = Shade.SkinEngine

local Skin = {}
function Skin.Apply(btn, ctx, o, base)
  base:BaseApply(btn, ctx, o)
  -- neon overlay
  if not btn.__shade_neon then
    local n = btn:CreateTexture(nil, 'OVERLAY')
    n:SetPoint('TOPLEFT', -1, 1); n:SetPoint('BOTTOMRIGHT', 1, -1)
    n:SetTexture('Interface/Buttons/WHITE8x8'); btn.__shade_neon = n
  end
  local c = {0.2,0.8,1,1}
  btn.__shade_neon:SetColorTexture(c[1],c[2],c[3],0.25)
end

SE:RegisterSkin('neon', Skin)
