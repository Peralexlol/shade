--[=[
File: modules/Auras.lua (v0.1.1)
Retail-safe aura styling. No dependency on removed functions.
]=]

local Shade = _G.Shade
local API = Shade.API

local M = { name = 'auras' }

local function add(btn)
  if not btn or btn.__shade_added then return end
  btn.__shade_added = true
  M.group = M.group or API:RegisterGroup('Shade', 'Auras')
  M.group:AddButton(btn, 'AURA')
end

-- Walk children to discover icon-holding buttons (retail containers)
local function walk(parent, depth)
  if not parent or depth > 3 then return end
  local name = parent.GetName and parent:GetName()
  local icon = (name and _G[name..'Icon']) or parent.Icon or parent.icon or parent.IconTexture or parent.iconTexture
  if icon then add(parent) end
  local n = parent.GetNumChildren and parent:GetNumChildren() or 0
  for i = 1, n do
    local child = select(i, parent:GetChildren())
    walk(child, depth + 1)
  end
end

local function scan()
  -- Classic-style globals if they exist
  for i=1,40 do add(_G['BuffButton'..i]); add(_G['DebuffButton'..i]) end
  -- Retail containers
  if BuffFrame then walk(BuffFrame, 0) end
end

function M:Enable()
  scan()
  local f = CreateFrame('Frame')
  f:RegisterEvent('PLAYER_ENTERING_WORLD')
  f:RegisterUnitEvent('UNIT_AURA', 'player')
  f:RegisterUnitEvent('UNIT_AURA', 'target')
  f:RegisterUnitEvent('UNIT_AURA', 'focus')
  f:SetScript('OnEvent', function() scan() end)
end

function M:ReskinAll() scan() end

Shade:RegisterModule(M.name, M)
