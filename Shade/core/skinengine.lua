--[=[
File: core/SkinEngine.lua (v0.1.1)
Button skin application + skin registry (retail-safe, no-backdrop fallback).
]=]

local ADDON_NAME = ...
local Shade = _G.Shade

local SE = { skins = {} }

-- Register a skin module
function SE:RegisterSkin(key, skin)
  self.skins[key] = skin
end

function SE:GetActiveSkin()
  local p = Shade:GetProfileTable()
  local key = (p and p.skin) or 'glass'
  return self.skins[key] or self.skins['glass']
end

-- helpers
local function ensureLayer(parent, layer, name)
  local t = parent:CreateTexture(name, layer)
  t:SetAllPoints(parent)
  return t
end

local function cropIcon(icon)
  if not icon or not icon.SetTexCoord then return end
  icon:SetTexCoord(.08, .92, .08, .92)
end

local function fetchIcon(btn)
  return btn.icon or btn.Icon or btn.iconTexture or _G[btn:GetName() and (btn:GetName()..'Icon') or '']
end

local function ensureBackdrop(f)
  if not f.SetBackdrop then return end
  if not f.__shade_bd then
    f:SetBackdrop({ bgFile = 'Interface/Buttons/WHITE8x8', edgeFile = 'Interface/Buttons/WHITE8x8', edgeSize = 1, insets = {left=1,right=1,top=1,bottom=1} })
    f.__shade_bd = true
  end
end

-- Base style every skin can use (safe for frames WITHOUT BackdropTemplate)
function SE:BaseApply(btn, ctx, o)
  if not btn or not btn.GetObjectType then return end
  o = o or {}
  local P = Shade:GetProfileTable()
  local border = o.border or P.border or 2
  local alpha  = o.alpha  or P.alpha  or 1
  local gloss  = o.gloss  or P.gloss  or 0

  -- icon
  local icon = fetchIcon(btn)
  if icon then icon:ClearAllPoints(); icon:SetPoint('TOPLEFT', border, -border); icon:SetPoint('BOTTOMRIGHT', -border, border); cropIcon(icon) end

  -- backdrop or texture fallback
  if btn.SetBackdrop then
    ensureBackdrop(btn)
    btn:SetBackdropColor(0,0,0,alpha)
    btn:SetBackdropBorderColor(0,0,0,1)
    if btn.__shade_bg then btn.__shade_bg:Hide() end
  else
    if not btn.__shade_bg then
      local bg = btn:CreateTexture(nil, 'BACKGROUND')
      bg:SetPoint('TOPLEFT')
      bg:SetPoint('BOTTOMRIGHT')
      btn.__shade_bg = bg
    end
    btn.__shade_bg:Show()
    btn.__shade_bg:SetColorTexture(0,0,0,alpha)
  end

  -- shadow (subtle outer)
  if not btn.__shade_shadow then
    local s = ensureLayer(btn, 'BACKGROUND')
    s:SetColorTexture(0,0,0,0.35)
    s:SetPoint('TOPLEFT', -2, 2)
    s:SetPoint('BOTTOMRIGHT', 2, -2)
    btn.__shade_shadow = s
  end

  -- gloss
  if gloss > 0 then
    if not btn.__shade_gloss then
      local g = btn:CreateTexture(nil, 'ARTWORK')
      g:SetPoint('TOPLEFT', border, -border)
      g:SetPoint('BOTTOMRIGHT', -border, border)
      g:SetTexture(Shade.media.stripe, 'REPEAT', 'REPEAT')
      btn.__shade_gloss = g
    end
    btn.__shade_gloss:SetAlpha(gloss)
  elseif btn.__shade_gloss then
    btn.__shade_gloss:SetAlpha(0)
  end
end

-- Apply using the active skin
function SE.ApplyButton(btn, ctx, opts)
  local skin = SE:GetActiveSkin()
  if not skin or not skin.Apply then return SE:BaseApply(btn, ctx, opts) end
  skin.Apply(btn, ctx, opts, SE)
end

Shade.SkinEngine = SE
