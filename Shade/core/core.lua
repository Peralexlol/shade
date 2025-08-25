-- File: Shade/core/core.lua
-- Purpose: SUI‑Dark theme (v3), optional .tga media without "shade_" prefix, helpers.

local ADDON, Shade = ...
Shade = Shade or _G.Shade or {}
_G.Shade = Shade

Shade.const = Shade.const or {}

-- Base media folder
local BASE = "Interface\\AddOns\\Shade\\media\\"

-- Your files are .tga and have no "shade_" prefix; map them here
Shade.media = {
  panel_noise       = BASE .. "panel_noise_64.tga",
  panel_gloss       = BASE .. "panel_gloss_256x64.tga",
  panel_vignette    = BASE .. "panel_vignette_512.tga",
  inset_fill        = BASE .. "inset_fill_64.tga",
  separator         = BASE .. "separator_1x2.tga",
  button_fill       = BASE .. "button_fill_64x32.tga",
  button_gloss      = BASE .. "button_gloss_64x16.tga",
  button_hover      = BASE .. "button_hover_64x32.tga",
  button_down       = BASE .. "button_down_64x32.tga",
  checkbox_check    = BASE .. "checkbox_check_16.tga",
  dropdown_arrow    = BASE .. "dropdown_arrow_16.tga",
  slider_thumb      = BASE .. "slider_thumb_10x18.tga",
  scroll_track      = BASE .. "scroll_track_8x64.tga",
  scroll_thumb      = BASE .. "scroll_thumb_8x24.tga",
  input_bg          = BASE .. "input_bg_64.tga",
  tab_active        = BASE .. "tab_active_64x32.tga",
  tab_inactive      = BASE .. "tab_inactive_64x32.tga",
}

function Shade:HasFile(path)
  if not path or path == "" then return false end
  if type(GetFileIDFromPath) == "function" then
    return GetFileIDFromPath(path) ~= nil
  end
  -- fallback: try to load via CreateTexture probe (safe, but we avoid to keep perf)
  return false
end

local function rgb(r,g,b,a) return {r or 1,g or 1,b or 1,a or 1} end

Shade.const.themes = Shade.const.themes or {}

-- SUI‑Dark tuned darker with gold accent
Shade.const.themes["sui-dark"] = {
  name   = "SUI Dark",
  base   = rgb(0.08, 0.08, 0.09, 0.98),
  raised = rgb(0.11, 0.11, 0.12, 0.99),
  sunken = rgb(0.06, 0.06, 0.07, 1.00),
  border = rgb(0.02, 0.02, 0.02, 1.00),
  edge   = rgb(0.15, 0.15, 0.16, 1.00),
  glow   = rgb(0.90, 0.90, 0.95, 0.08),
  accent = rgb(0.92, 0.76, 0.16, 1.00),
  text   = rgb(0.90, 0.90, 0.92, 1.00),
  weak   = rgb(0.65, 0.65, 0.68, 1.00),
  focus  = rgb(0.96, 0.86, 0.20, 0.15),
  radius = 6,
  pad    = 8,
  line   = 1,
}

ShadeDB       = _G.ShadeDB or { theme = "sui-dark" }
_G.ShadeDB    = ShadeDB
Shade.theme   = Shade.const.themes[ShadeDB.theme] or Shade.const.themes["sui-dark"]

function Shade:ApplyTheme(key)
  local t = Shade.const.themes[key]
  if not t then return false end
  ShadeDB.theme = key
  Shade.theme   = t
  if Shade.UI and Shade.UI.ApplyTheme then pcall(Shade.UI.ApplyTheme, Shade.UI, t) end
  return true
end

function Shade:GetTheme() return Shade.theme end

Shade.modules = Shade.modules or {}
function Shade:RegisterModule(key, mod) self.modules[key] = mod; return mod end
