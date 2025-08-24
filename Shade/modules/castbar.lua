--[=[
File: modules/Castbar.lua
Styles player/target/focus castbars.
]=]

local Shade = _G.Shade

local M = { name = 'castbar' }

local function skinBar(cb)
  if not cb or cb.__shade_cb then return end
  cb.__shade_cb = true
  if cb.SetBackdrop then
    cb:SetBackdrop({ bgFile='Interface/Buttons/WHITE8x8', edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
    cb:SetBackdropColor(0.10,0.11,0.13,1)
    cb:SetBackdropBorderColor(0,0,0,0.9)
  end
  if cb.Icon then cb.Icon:SetTexCoord(.08,.92,.08,.92) end
end

function M:Enable()
  local bars = { PlayerCastingBarFrame, TargetFrame and TargetFrame.castbar, FocusFrame and FocusFrame.castbar }
  for _,cb in ipairs(bars) do if cb then skinBar(cb) end end
end

function M:ReskinAll() self:Enable() end

Shade:RegisterModule(M.name, M)
