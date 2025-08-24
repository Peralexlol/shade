--[=[
File: modules/Misc.lua
Small extras: Game Menu, Objectives, Queue pop.
]=]

local Shade = _G.Shade

local M = { name = 'misc' }

local function backdrop(f)
  if not f or f.__shade_bd then return end
  f.__shade_bd = true
  if f.SetBackdrop then
    f:SetBackdrop({ bgFile='Interface/Buttons/WHITE8x8', edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
    f:SetBackdropColor(0.10,0.11,0.13,1)
    f:SetBackdropBorderColor(0,0,0,0.9)
  end
end

local function styleGameMenu()
  if GameMenuFrame then backdrop(GameMenuFrame) end
end

local function styleObjectives()
  if ObjectiveTrackerFrame and ObjectiveTrackerFrame.HeaderMenu then
    backdrop(ObjectiveTrackerFrame)
  end
end

local function styleQueuePop()
  if LFDRoleCheckPopup then backdrop(LFDRoleCheckPopup) end
  if LFGInvitePopup then backdrop(LFGInvitePopup) end
end

function M:Enable()
  styleGameMenu(); styleObjectives(); styleQueuePop()
end

function M:ReskinAll() self:Enable() end

Shade:RegisterModule(M.name, M)
