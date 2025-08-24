-- File: Shade/core/core.lua
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- Provides: Shade.const, module registry (Shade:RegisterModule/NewModule), simple lifecycle.

local addonName = ... or "Shade"

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

-- ------------------------------------------------------------------
-- Constants / shared paths
-- ------------------------------------------------------------------
Shade.const = Shade.const or {
  ADDON = addonName,
  MEDIA = "Interface\\AddOns\\Shade\\media\\",
}

-- ------------------------------------------------------------------
-- Module system (very small + tolerant)
-- ------------------------------------------------------------------
Shade.modules = Shade.modules or {}

local function normalize(name, mod)
  if type(name) == "table" and mod == nil then
    mod = name
    name = mod.name
  end
  name = tostring(name or mod and mod.name or ("module_"..(tostring(#(Shade.modules) + 1))))
  mod = mod or {}
  mod.name = mod.name or name
  return name, mod
end

--- Create (but do not register) a new module table
function Shade.NewModule(name)
  local n, m = normalize(name, {})
  m.enabled = true
  return m
end

--- Register a module table (or name + table). Returns the stored module.
function Shade:RegisterModule(name, mod)
  local n, m = normalize(name, mod)
  m.enabled = (m.enabled ~= false)
  Shade.modules[n] = m
  return m
end

-- ------------------------------------------------------------------
-- Lifecycle: fire OnInit and OnEnable at login
-- ------------------------------------------------------------------
local function safe_call(m, fn)
  local f = m and m[fn]
  if type(f) == "function" then
    local ok, err = pcall(f, m)
    if not ok then
      print("|cff8059f2Shade|r: module '"..(m.name or "?").."' "..fn.." error:", err)
    end
  end
end

local fired
local function boot()
  if fired then return end
  fired = true
  for _, m in pairs(Shade.modules) do
    safe_call(m, "OnInit")
  end
  for _, m in pairs(Shade.modules) do
    if m.enabled ~= false then safe_call(m, "OnEnable") end
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, evt, name)
  if evt == "ADDON_LOADED" and name == addonName then
    -- Allow modules that were registered during loading to run init/enable after all files loaded
    C_Timer.After(0, boot)
  elseif evt == "PLAYER_LOGIN" then
    boot()
  end
end)

-- ------------------------------------------------------------------
-- Minimal SkinEngine stub (keeps modules happy; customize later)
-- ------------------------------------------------------------------
Shade.SkinEngine = Shade.SkinEngine or {}
local SE = Shade.SkinEngine
function SE:SkinFrame(frame) return frame end
function SE:SkinButton(btn) return btn end
function SE:SkinTooltip(tt) return tt end
function SE:SkinStatusBar(sb) return sb end
