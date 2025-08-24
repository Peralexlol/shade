--[=[
File: core/API.lua
Public API for authors: RegisterGroup + AddButton.
]=]

local ADDON_NAME = ...
local Shade = _G.Shade

local Groups = {}
local Buttons = setmetatable({}, { __mode = 'k' }) -- weak keys

local function key(addon, group)
  return (addon or 'unknown')..":"..(group or 'default')
end

local function applyNow(btn, ctx, opts)
  if not btn or not btn.GetObjectType then return end
  if Shade.SkinEngine then Shade.SkinEngine.ApplyButton(btn, ctx, opts) end
end

-- API object
local API = {}

-- Create a group for an addon
function API:RegisterGroup(addonName, groupName, opts)
  local k = key(addonName, groupName)
  if not Groups[k] then
    Groups[k] = {
      addon = addonName,
      name = groupName,
      opts = opts or {},
      buttons = {},
    }
  end
  return setmetatable({ _k = k }, {
    __index = {
      AddButton = function(self, button, kind, id, bopts)
        if not button then return end
        local g = Groups[self._k]
        g.buttons[#g.buttons+1] = button
        Buttons[button] = { kind = kind, id = id, group = self._k, opts = bopts }
        if InCombatLockdown() then
          Shade.util.runAfterCombat(function() applyNow(button, kind, bopts or g.opts) end)
        else
          applyNow(button, kind, bopts or g.opts)
        end
      end,
    }
  })
end

-- Reapply all (profile/skin change)
function API.ReskinAll()
  for btn, meta in pairs(Buttons) do
    Shade.util.safeCall(function()
      if btn and btn.GetObjectType then
        applyNow(btn, meta.kind, meta.opts)
      end
    end)
  end
end

Shade.API = API
