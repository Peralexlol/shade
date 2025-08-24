--[=[
File: modules/ActionButtons.lua (v0.1.2)
Retail-safe action button discovery with event-based rescans.
Guarded icon lookup to avoid nil concatenation.
]=]

local Shade = _G.Shade
local API = Shade.API

local M = { name = 'actionbuttons' }

local function getIcon(btn)
  if not btn then return nil end
  if btn.icon then return btn.icon end
  if btn.Icon then return btn.Icon end
  if btn.iconTexture then return btn.iconTexture end
  if btn.IconTexture then return btn.IconTexture end
  local name = (btn.GetName and btn:GetName()) or nil
  if name then
    return _G[name..'Icon'] or _G[name..'IconTexture']
  end
  return nil
end

local function isButtonLike(btn)
  local t = btn.GetObjectType and btn:GetObjectType()
  return t == 'CheckButton' or t == 'Button' or btn.action ~= nil
end

local function add(btn)
  if not btn or btn.__shade_added then return end
  if not isButtonLike(btn) then return end
  local icon = getIcon(btn)
  if not icon then return end
  btn.__shade_added = true
  M.group = M.group or API:RegisterGroup('Shade', 'ActionButtons')
  M.group:AddButton(btn, 'ACTION')
end

local function scanPrefix(prefix, n)
  for i = 1, (n or 48) do
    local b = _G[prefix..i]
    if b then add(b) end
  end
end

local function walkChildren(frame, depth)
  if not frame or depth > 3 then return end
  local num = frame.GetNumChildren and frame:GetNumChildren() or 0
  for i = 1, num do
    local child = select(i, frame:GetChildren())
    if child then add(child); walkChildren(child, depth + 1) end
  end
end

local function scanAll()
  -- Classic/Retail common prefixes
  scanPrefix('ActionButton', 24)
  scanPrefix('MultiBarBottomLeftButton', 24)
  scanPrefix('MultiBarBottomRightButton', 24)
  scanPrefix('MultiBarRightButton', 24)
  scanPrefix('MultiBarLeftButton', 24)
  -- Dragonflight extra bars
  scanPrefix('MultiBar5Button', 24)
  scanPrefix('MultiBar6Button', 24)
  scanPrefix('MultiBar7Button', 24)
  -- Pet/Stance/Possess/Extra
  scanPrefix('PetActionButton', 10)
  scanPrefix('StanceButton', 10)
  scanPrefix('PossessButton', 2)
  scanPrefix('ExtraActionButton', 1)

  -- Walk known containers for unnamed mixin buttons
  local containers = {
    _G.MainMenuBar,
    _G.MultiBarBottomLeft,
    _G.MultiBarBottomRight,
    _G.MultiBarRight,
    _G.MultiBarLeft,
    _G.MultiBar5,
    _G.MultiBar6,
    _G.MultiBar7,
    _G.PetActionBar,
    _G.StanceBar,
    _G.PossessBarFrame,
    _G.ExtraActionBarFrame,
  }
  for _, f in ipairs(containers) do if f then walkChildren(f, 0) end end
end

function M:Enable()
  scanAll()
  if type(_G.ActionBarController_UpdateAll) == 'function' then
    hooksecurefunc('ActionBarController_UpdateAll', scanAll)
  end

  local ev = CreateFrame('Frame')
  ev:RegisterEvent('PLAYER_ENTERING_WORLD')
  ev:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
  ev:RegisterEvent('ACTIONBAR_UPDATE_STATE')
  ev:RegisterEvent('ACTIONBAR_SHOWGRID')
  ev:RegisterEvent('ACTIONBAR_HIDEGRID')
  ev:RegisterEvent('UPDATE_BINDINGS')
  ev:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
  ev:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR')
  ev:RegisterEvent('PLAYER_TALENT_UPDATE')
  ev:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
  ev:RegisterEvent('PET_BAR_UPDATE')
  ev:RegisterEvent('SPELLS_CHANGED')
  ev:SetScript('OnEvent', function() scanAll() end)
end

function M:ReskinAll() scanAll() end

Shade:RegisterModule(M.name, M)
