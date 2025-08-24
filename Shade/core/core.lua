--[=[
File: core/Core.lua
Addon: Shade - UI Skin Engine
Author: Peralex

Bootstrap, events, DB, simple utils.
]=]

local ADDON_NAME = ...
local Shade = _G.Shade or {}
_G.Shade = Shade

-- Versioning
Shade.version = '0.1.0'

------------------------------------------------------------
-- SavedVariables (global + per char)
------------------------------------------------------------
local DEFAULTS = {
  profile = 'Default',
  profiles = {
    Default = {
      skin = 'glass',
      border = 2,
      alpha = 1.0,
      gloss = 0.25,
      modules = {
        actionbuttons = true,
        auras = true,
        tooltips = true,
        castbar = true,
        chat = true,
        misc = true,
      },
    },
  },
}

-- Locals for SV refs
local SV, SVChar

------------------------------------------------------------
-- Utils
------------------------------------------------------------
local function deepcopy(t)
  if type(t) ~= 'table' then return t end
  local r = {}
  for k,v in pairs(t) do r[k] = deepcopy(v) end
  return r
end

local function getProfile()
  local name = SV.profile or 'Default'
  SV.profiles = SV.profiles or {}
  SV.profiles[name] = SV.profiles[name] or deepcopy(DEFAULTS.profiles.Default)
  return SV.profiles[name]
end

Shade.util = {
  deepcopy = deepcopy,
  -- After-combat queue.
  inCombat = function() return InCombatLockdown() end,
  runAfterCombat = function(fn)
    if not fn then return end
    if InCombatLockdown() then
      Shade._queue[#Shade._queue+1] = fn
    else fn() end
  end,
  safeCall = function(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then geterrorhandler()(('|cffff4444Shade error:|r %s'):format(err)) end
  end,
}

------------------------------------------------------------
-- Event frame
------------------------------------------------------------
Shade._queue = {}
Shade.events = CreateFrame('Frame')
Shade.events:RegisterEvent('ADDON_LOADED')
Shade.events:RegisterEvent('PLAYER_LOGIN')
Shade.events:RegisterEvent('PLAYER_REGEN_ENABLED')
Shade.events:SetScript('OnEvent', function(_, evt, ...)
  if evt == 'ADDON_LOADED' then
    local name = ...
    if name == ADDON_NAME then
      _G.ShadeDB = _G.ShadeDB or deepcopy(DEFAULTS)
      _G.ShadeDBChar = _G.ShadeDBChar or {}
      SV, SVChar = _G.ShadeDB, _G.ShadeDBChar
      -- Migrate simple shape
      SV.profiles = SV.profiles or { Default = deepcopy(DEFAULTS.profiles.Default) }
      SV.profile = SV.profile or 'Default'
    end
  elseif evt == 'PLAYER_LOGIN' then
    Shade.profile = getProfile()
    -- Load modules as requested
    Shade:EnableConfiguredModules()
    -- Build config UI lazily on first slash
    Shade:InitSlash()
  elseif evt == 'PLAYER_REGEN_ENABLED' then
    if #Shade._queue > 0 then
      local q = Shade._queue
      Shade._queue = {}
      for i=1,#q do local fn = q[i]; Shade.util.safeCall(fn) end
    end
  end
end)

------------------------------------------------------------
-- Module handling
------------------------------------------------------------
Shade.modules = {}

function Shade:RegisterModule(name, mod)
  self.modules[name] = mod
  if self.profile and self.profile.modules[name] then
    Shade.util.safeCall(function() mod:Enable() end)
  end
end

function Shade:EnableConfiguredModules()
  for name, mod in pairs(self.modules) do
    if self.profile.modules[name] then Shade.util.safeCall(function() mod:Enable() end) end
  end
end

function Shade:ReapplyAll()
  -- Reskin all groups/buttons
  if Shade.API and Shade.API.ReskinAll then Shade.API.ReskinAll() end
  -- Modules may have extra visuals
  for _, mod in pairs(self.modules) do
    if mod.ReskinAll then Shade.util.safeCall(function() mod:ReskinAll() end) end
  end
end

------------------------------------------------------------
-- Profile switching
------------------------------------------------------------
function Shade:SetProfile(name)
  if type(name) ~= 'string' or name == '' then return end
  SV.profile = name
  if not SV.profiles[name] then SV.profiles[name] = deepcopy(DEFAULTS.profiles.Default) end
  self.profile = getProfile()
  self:ReapplyAll()
end

function Shade:GetProfiles()
  local list = {}
  for n in pairs(SV.profiles or {}) do list[#list+1] = n end
  table.sort(list)
  return list
end

function Shade:GetProfileTable() return getProfile() end
function Shade:GetSV() return SV end

------------------------------------------------------------
-- Slash
------------------------------------------------------------
function Shade:InitSlash()
  SLASH_SHADE1 = '/shade'
  SlashCmdList.SHADE = function()
    if ShadeUI and ShadeUI.Toggle then ShadeUI.Toggle() end
  end
end

------------------------------------------------------------
-- Expose namespaces for other files
------------------------------------------------------------
Shade.ns = Shade.ns or {}
Shade.const = Shade.const or {}
Shade.media = {
  noise = 'Interface/AddOns/'..ADDON_NAME..'/media/noise.tga',
  stripe = 'Interface/AddOns/'..ADDON_NAME..'/media/stripe.tga',
  font = 'Interface/AddOns/'..ADDON_NAME..'/media/fonts/Oxanium-ExtraBold.ttf',
}

-- Color constants (dark-first)
Shade.const.colors = {
  bg   = {0.10, 0.11, 0.13, 1.00},
  bg2  = {0.13, 0.14, 0.17, 1.00},
  group= {0.15, 0.16, 0.19, 1.00},
  line = {0,0,0,0.90},
  accent = {1.00, 0.82, 0.00, 1.00},
  text = {1,1,1,1},
}
