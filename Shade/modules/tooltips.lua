--[=[
File: modules/Tooltips.lua
Glass-style tooltips (GameTooltip + friends).
]=]

local Shade = _G.Shade
local C = Shade.const.colors

local M = { name = 'tooltips' }

local function skinTip(tip)
  if not tip or tip.__shade_tip then return end
  tip.__shade_tip = true
  if tip.SetBackdrop then
    tip:SetBackdrop({ bgFile='Interface/Buttons/WHITE8x8', edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
    tip:SetBackdropColor(0.08,0.09,0.11,0.95)
    tip:SetBackdropBorderColor(0,0,0,0.9)
  end
end

function M:Enable()
  local tips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, EmbeddedItemTooltip } 
  for _,t in ipairs(tips) do if t then skinTip(t) end end
end

Shade:RegisterModule(M.name, M)
