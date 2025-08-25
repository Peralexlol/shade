-- File: shade/skins/shade_ui.lua

local Shade = _G.Shade
Shade.Skins = Shade.Skins or {}

local H2RGB = _G.HexToRGB
local r,g,b
if H2RGB then r,g,b = H2RGB("#232323") else r,g,b = 35/255, 35/255, 35/255 end
local pr,pg,pb = 0.42, 0.16, 0.59 -- dark purple accent

Shade.Skins["Shade UI"] = {
  name = "Shade UI",
  bg = { r, g, b, 0.98 },
  border = { pr, pg, pb, 0.9 },
  accent = { pr, pg, pb, 1.0 },
}
