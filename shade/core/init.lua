-- File: shade/core/init.lua (complete, wrapper fix)

local ADDON_NAME = ...

-- Global namespace
local Shade = _G.Shade or {}
_G.Shade = Shade

-- Metadata
Shade.VERSION = "0.1.0"
Shade.ADDON_NAME = ADDON_NAME
Shade.PRIVATE = Shade.PRIVATE or { queued = false, queue = {} }

-- Wrap util exports so method syntax (:) doesn't pass Shade as host
function Shade:StylePanel(frame)
  if _G.Shade_StylePanel then return _G.Shade_StylePanel(frame) end
end
function Shade:EnsureBorder(host)
  if _G.Shade_EnsureBorder then return _G.Shade_EnsureBorder(host) end
end
function Shade:EnsureOverlay(host, key, strata)
  if _G.Shade_EnsureOverlay then return _G.Shade_EnsureOverlay(host, key, strata) end
end

-- Defaults
local DEFAULTS = {
  profile = {
    name = "Default",
    theme = "Shade UI",
    actionbars = {
      enabled = true,
      borderThickness = 2,
      alpha = 0.92,
      gloss = 0.12,
    },
  },
}

-- Event frame
local f = CreateFrame("Frame")
Shade.EventFrame = f

-- Pull util functions (with tiny fallbacks)
local DeepCopy = _G.DeepCopy
local DeepMerge = _G.DeepMerge

if not DeepCopy then
  function DeepCopy(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local t = {}
    for k,v in pairs(tbl) do t[k] = DeepCopy(v) end
    return t
  end
end
if not DeepMerge then
  function DeepMerge(dst, src)
    dst = dst or {}
    for k,v in pairs(src or {}) do
      if type(v) == 'table' and type(dst[k]) == 'table' then
        DeepMerge(dst[k], v)
      else
        dst[k] = v
      end
    end
    return dst
  end
end

-- SavedVariables bootstrapping
local function InitDB()
  if not ShadeDB then ShadeDB = {} end
  ShadeDB.global = ShadeDB.global or { profiles = { Default = DeepCopy(DEFAULTS.profile) } }
  local charKey = UnitName("player") .. "-" .. GetRealmName()
  ShadeDB.char = ShadeDB.char or {}
  ShadeDB.char[charKey] = ShadeDB.char[charKey] or { profile = "Default" }
end

function Shade:GetCharKey()
  return UnitName("player") .. "-" .. GetRealmName()
end

function Shade:GetProfileName()
  local key = self:GetCharKey()
  return (ShadeDB.char and ShadeDB.char[key] and ShadeDB.char[key].profile) or "Default"
end

function Shade:GetProfile()
  if not ShadeDB or not ShadeDB.global then InitDB() end
  local name = self:GetProfileName()
  local prof = ShadeDB.global.profiles[name]
  if not prof then
    prof = DeepCopy(DEFAULTS.profile)
    ShadeDB.global.profiles[name] = prof
  end
  return prof
end

function Shade:SetProfile(name)
  if not name or name == "" then return end
  local key = self:GetCharKey()
  ShadeDB.char[key] = ShadeDB.char[key] or {}
  ShadeDB.char[key].profile = name
  if not ShadeDB.global.profiles[name] then
    ShadeDB.global.profiles[name] = DeepCopy(DEFAULTS.profile)
  end
  self:ReskinAll()
end

-- Settings accessors
function Shade:GetActionbarSettings()
  local p = self:GetProfile()
  p.actionbars = p.actionbars or DeepCopy(DEFAULTS.profile.actionbars)
  return p.actionbars
end

function Shade:UpdateActionbarSettings(new)
  local p = self:GetProfile()
  p.actionbars = DeepMerge(p.actionbars or {}, new)
  self:ReskinActionbars()
end

-- Deferred apply when in combat
local function DrainQueue()
  if InCombatLockdown() then return end
  Shade.PRIVATE.queued = false
  for i = 1, #Shade.PRIVATE.queue do
    pcall(Shade.PRIVATE.queue[i])
  end
  wipe(Shade.PRIVATE.queue)
end

function Shade:DeferSafe(fn)
  if InCombatLockdown() then
    table.insert(self.PRIVATE.queue, fn)
    self.PRIVATE.queued = true
  else
    fn()
  end
end

-- Group registry (used by API)
Shade.Groups = Shade.Groups or {}

function Shade:ReskinGroup(id)
  local g = self.Groups[id]
  if not g then return end
  if g.reskin then g:reskin() end
end

function Shade:ReskinAll()
  for id in pairs(self.Groups) do self:ReskinGroup(id) end
end

function Shade:ReskinActionbars()
  self:ReskinGroup("blizzard/actionbars")
end

-- Slash command
SLASH_SHADE1 = "/shade"
SlashCmdList["SHADE"] = function()
  if ShadeOptions_Toggle then ShadeOptions_Toggle() end
end

-- Events
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

f:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    InitDB()
  elseif event == "PLAYER_LOGOUT" then
    -- reserved
  elseif event == "PLAYER_REGEN_ENABLED" then
    if Shade.PRIVATE.queued then DrainQueue() end
  end
end)

-- Logging
function Shade:Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cFF8A2BE2Shade|r: " .. (msg or ""))
end

-- Profile import/export (util-backed)
function Shade:ExportConfig(tbl)
  if _G.Shade_ExportConfig then return _G.Shade_ExportConfig(tbl) end
  return ""
end
function Shade:ImportConfig(str)
  if _G.Shade_ImportConfig then return _G.Shade_ImportConfig(str) end
  return nil, 'Import unavailable'
end

-- Expose defaults for other modules
function Shade:GetDefaults() return DEFAULTS end
