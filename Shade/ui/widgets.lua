-- File: Shade/ui/widgets.lua
-- Purpose: Use your .tga assets (no prefix) when present, with graceful fallbacks.

local ADDON, Shade = ...
local W = Shade.Widgets or {}
Shade.Widgets = W

local UI = Shade.UI or {}; Shade.UI = UI

local WHITE = [[Interface\Buttons\WHITE8x8]]

local function color(tex, c) tex:SetTexture(WHITE); tex:SetVertexColor(c[1], c[2], c[3], c[4]) end
local function setAlpha(tex, a) local r,g,b = tex:GetVertexColor(); tex:SetVertexColor(r or 1, g or 1, b or 1, a) end
local function px(frame, n) return (n or 1) / (frame:GetEffectiveScale()) end

local function setBorder(frame, cOuter, cInner)
  local l = Shade.theme.line or 1
  frame.__bd = frame.__bd or {}
  local bd = frame.__bd
  local s = frame
  local function edge(which)
    local t = bd[which] or s:CreateTexture(nil, "BORDER"); bd[which] = t
    t:SetTexture(WHITE); t:SetVertexColor(cOuter[1], cOuter[2], cOuter[3], cOuter[4])
    return t
  end
  local function inset(which)
    local t = bd["in_"..which] or s:CreateTexture(nil, "BORDER"); bd["in_"..which] = t
    t:SetTexture(WHITE); t:SetVertexColor(cInner[1], cInner[2], cInner[3], cInner[4])
    return t
  end
  local r = px(s, l)
  edge("top"):SetPoint("TOPLEFT"); edge("top"):SetPoint("TOPRIGHT"); edge("top"):SetHeight(r)
  edge("bottom"):SetPoint("BOTTOMLEFT"); edge("bottom"):SetPoint("BOTTOMRIGHT"); edge("bottom"):SetHeight(r)
  edge("left"):SetPoint("TOPLEFT"); edge("left"):SetPoint("BOTTOMLEFT"); edge("left"):SetWidth(r)
  edge("right"):SetPoint("TOPRIGHT"); edge("right"):SetPoint("BOTTOMRIGHT"); edge("right"):SetWidth(r)
  local r2 = px(s, l)
  inset("top"):SetPoint("TOPLEFT", 0, -r); inset("top"):SetPoint("TOPRIGHT", 0, -r); inset("top"):SetHeight(r2)
  inset("bottom"):SetPoint("BOTTOMLEFT", 0, r); inset("bottom"):SetPoint("BOTTOMRIGHT", 0, r); inset("bottom"):SetHeight(r2)
  inset("left"):SetPoint("TOPLEFT", r, 0); inset("left"):SetPoint("BOTTOMLEFT", r, 0); inset("left"):SetWidth(r2)
  inset("right"):SetPoint("TOPRIGHT", -r, 0); inset("right"):SetPoint("BOTTOMRIGHT", -r, 0); inset("right"):SetWidth(r2)
end

local function setPanelBG(frame, col)
  frame.__bg = frame.__bg or frame:CreateTexture(nil, "BACKGROUND")
  frame.__bg:SetAllPoints(); color(frame.__bg, col); return frame.__bg
end

local function setInnerGlow(frame, col)
  frame.__glow = frame.__glow or frame:CreateTexture(nil, "BORDER")
  frame.__glow:SetPoint("TOPLEFT", 1, -1); frame.__glow:SetPoint("BOTTOMRIGHT", -1, 1)
  color(frame.__glow, col); return frame.__glow
end

-- CLOSE BUTTON ---------------------------------------------------------------
function W.CloseButton(parent)
  local b = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
  b:SetSize(20, 20)
  return b
end

-- Optional overlays ----------------------------------------------------------
local function applyOptionalOverlays(frame)
  local M = Shade.media
  frame.__overlays = frame.__overlays or {}; local O = frame.__overlays

  local noise = O.noise or frame:CreateTexture(nil, "ARTWORK"); O.noise = noise
  noise:SetAllPoints(); noise:SetBlendMode("MOD")
  if Shade:HasFile(M.panel_noise) then noise:SetTexture(M.panel_noise); setAlpha(noise, 0.06); noise:Show() else noise:Hide() end

  local gloss = O.gloss or frame:CreateTexture(nil, "ARTWORK"); O.gloss = gloss
  gloss:SetBlendMode("BLEND")
  local function sizeGloss()
    local h = math.max(20, math.min(64, (frame:GetHeight() or 200) * 0.22))
    gloss:ClearAllPoints(); gloss:SetPoint("TOPLEFT", 1, -1); gloss:SetPoint("TOPRIGHT", -1, -1); gloss:SetHeight(h)
  end
  frame:HookScript("OnSizeChanged", sizeGloss); sizeGloss()
  if Shade:HasFile(M.panel_gloss) then gloss:SetTexture(M.panel_gloss); setAlpha(gloss, 0.06); gloss:Show()
  else gloss:SetTexture(WHITE); if gloss.SetGradient then gloss:SetGradient("VERTICAL", CreateColor(1,1,1,0.06), CreateColor(1,1,1,0.00)) end; gloss:Show() end

  local vignette = O.vignette or frame:CreateTexture(nil, "OVERLAY"); O.vignette = vignette
  vignette:SetAllPoints(); vignette:SetBlendMode("MOD")
  if Shade:HasFile(M.panel_vignette) then vignette:SetTexture(M.panel_vignette); setAlpha(vignette, 0.05); vignette:Show() else vignette:Hide() end
end

local function applyCommonPanel(frame, raised)
  local T = Shade.theme
  setPanelBG(frame, raised and T.raised or T.base)
  setBorder(frame, T.edge, T.border)
  setInnerGlow(frame, T.glow)
  applyOptionalOverlays(frame)
end

-- WINDOW --------------------------------------------------------------------
function W.Window(name, width, height)
  local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
  f:SetSize(width, height); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG")
  applyCommonPanel(f, false)

  local acc = f:CreateTexture(nil, "ARTWORK"); acc:SetPoint("TOPLEFT", 1, -1); acc:SetPoint("TOPRIGHT", -1, -1); acc:SetHeight(2)
  color(acc, Shade.theme.accent); f.__accent = acc

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal"); title:SetPoint("TOPLEFT", 10, -8)
  title:SetTextColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3], 1); f.Title = title

  f.Close = W.CloseButton(f); f.Close:SetPoint("TOPRIGHT", -6, -6)

  function f:ApplyTheme(t) applyCommonPanel(self, false); color(acc, t.accent); title:SetTextColor(t.text[1], t.text[2], t.text[3], 1) end
  return f
end

-- SECTION -------------------------------------------------------------------
function W.Section(parent)
  local s = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  s:SetHeight(56); applyCommonPanel(s, true); return s
end

-- SEPARATOR -----------------------------------------------------------------
function W.Separator(parent)
  local t = parent:CreateTexture(nil, "ARTWORK")
  if Shade:HasFile(Shade.media.separator) then t:SetTexture(Shade.media.separator) else t:SetTexture(WHITE) end
  t:SetHeight(1); t:SetVertexColor(Shade.theme.edge[1], Shade.theme.edge[2], Shade.theme.edge[3], 0.9)
  return t
end

-- BUTTON --------------------------------------------------------------------
function W.Button(parent, label, width, height)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate"); b:SetSize(width or 120, height or 22)
  local M = Shade.media

  local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
  if Shade:HasFile(M.button_fill) then bg:SetTexture(M.button_fill); bg:SetHorizTile(true); setAlpha(bg, 1) else color(bg, Shade.theme.raised) end
  setBorder(b, Shade.theme.edge, Shade.theme.border)

  local strip = b:CreateTexture(nil, "BORDER")
  if Shade:HasFile(M.button_gloss) then strip:SetTexture(M.button_gloss); strip:SetPoint("TOPLEFT", 1, -1); strip:SetPoint("TOPRIGHT", -1, -1); strip:SetHeight(16); strip:SetBlendMode("ADD"); setAlpha(strip, 0.10)
  else strip:SetPoint("TOPLEFT", 1, -1); strip:SetPoint("TOPRIGHT", -1, -1); strip:SetHeight(1); color(strip, Shade.theme.glow) end

  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); fs:SetPoint("CENTER"); fs:SetText(label or "Button")
  fs:SetTextColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3], 1); b:SetFontString(fs)

  local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints()
  if Shade:HasFile(M.button_hover) then hl:SetTexture(M.button_hover); hl:SetBlendMode("ADD"); setAlpha(hl, 0.12) else color(hl, Shade.theme.focus) end

  b:HookScript("OnMouseDown", function(self)
    self:SetPushedTextOffset(0, -1)
    if Shade:HasFile(M.button_down) then hl:SetTexture(M.button_down); hl:SetBlendMode("BLEND"); setAlpha(hl, 0.35)
    else color(bg, {Shade.theme.raised[1]*0.9, Shade.theme.raised[2]*0.9, Shade.theme.raised[3]*0.9, Shade.theme.raised[4]}) end
  end)
  b:HookScript("OnMouseUp", function(self)
    self:SetPushedTextOffset(0, 0)
    if Shade:HasFile(M.button_hover) then hl:SetTexture(M.button_hover); hl:SetBlendMode("ADD"); setAlpha(hl, 0.12) else color(bg, Shade.theme.raised) end
  end)

  function b:ApplyTheme(t)
    if not Shade:HasFile(M.button_fill) then color(bg, t.raised) end
    setBorder(self, t.edge, t.border); fs:SetTextColor(t.text[1], t.text[2], t.text[3], 1)
    if not Shade:HasFile(M.button_gloss) then color(strip, t.glow) end
    if not Shade:HasFile(M.button_hover) then color(hl, t.focus) end
  end
  return b
end

-- EDIT BOX ------------------------------------------------------------------
function W.EditBox(parent, width)
  local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  e:SetAutoFocus(false); e:SetSize(width or 200, 24)
  local bg = e:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
  if Shade:HasFile(Shade.media.input_bg) then bg:SetTexture(Shade.media.input_bg); bg:SetHorizTile(true); bg:SetVertTile(true) else color(bg, Shade.theme.sunken) end
  setBorder(e, Shade.theme.edge, Shade.theme.border)
  e:SetTextColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3]); e:SetFontObject(GameFontHighlight)
  function e:ApplyTheme(t)
    if not Shade:HasFile(Shade.media.input_bg) then color(bg, t.sunken) end; setBorder(self, t.edge, t.border); self:SetTextColor(t.text[1], t.text[2], t.text[3])
  end
  return e
end

-- CHECKBOX ------------------------------------------------------------------
function W.Check(parent, labelText, checked, onChanged)
  local f = CreateFrame("Frame", nil, parent); f:SetSize(20, 20)
  local box = CreateFrame("CheckButton", nil, f); box:SetSize(16, 16); box:SetPoint("LEFT")

  local bg = box:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); color(bg, Shade.theme.sunken); setBorder(box, Shade.theme.edge, Shade.theme.border)

  if Shade:HasFile(Shade.media.checkbox_check) then box:SetCheckedTexture(Shade.media.checkbox_check) else box:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]]) end
  local tick = box:GetCheckedTexture(); tick:ClearAllPoints(); tick:SetAllPoints(); tick:SetVertexColor(1,1,1,1)

  box:SetHighlightTexture(WHITE)
  local hi = box:GetHighlightTexture(); hi:ClearAllPoints(); hi:SetAllPoints(); hi:SetBlendMode("ADD"); hi:SetVertexColor(Shade.theme.focus[1], Shade.theme.focus[2], Shade.theme.focus[3], Shade.theme.focus[4])

  local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); text:SetPoint("LEFT", box, "RIGHT", 6, 0)
  text:SetText(labelText or ""); text:SetTextColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3], 1)

  if checked ~= nil then box:SetChecked(checked) end
  box:HookScript("OnClick", function(self) if onChanged then pcall(onChanged, self:GetChecked()) end end)

  function f:GetChecked() return box:GetChecked() end
  function f:SetChecked(v) box:SetChecked(v and true or false) end
  function f:ApplyTheme(t) color(bg, t.sunken); setBorder(box, t.edge, t.border); text:SetTextColor(t.text[1], t.text[2], t.text[3], 1); hi:SetVertexColor(t.focus[1], t.focus[2], t.focus[3], t.focus[4]) end
  return f
end

-- SLIDER --------------------------------------------------------------------
function W.Slider(parent, minVal, maxVal, step)
  local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  s:SetMinMaxValues(minVal or 0, maxVal or 100); s:SetValueStep(step or 1); s:SetObeyStepOnDrag(true)

  local track = s:CreateTexture(nil, "BACKGROUND"); track:SetPoint("TOPLEFT", 0, -6); track:SetPoint("BOTTOMRIGHT", 0, 6)
  if Shade:HasFile(Shade.media.inset_fill) then track:SetTexture(Shade.media.inset_fill) else color(track, Shade.theme.sunken) end
  setBorder(s, Shade.theme.edge, Shade.theme.border)

  local th = s:CreateTexture(nil, "ARTWORK")
  if Shade:HasFile(Shade.media.slider_thumb) then th:SetTexture(Shade.media.slider_thumb) else th:SetTexture(WHITE); th:SetVertexColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3], 1) end
  th:SetSize(10, 18); s:SetThumbTexture(th)

  s:HookScript("OnMouseDown", function() th:SetWidth(12) end)
  s:HookScript("OnMouseUp",   function() th:SetWidth(10) end)

  function s:ApplyTheme(t)
    if not Shade:HasFile(Shade.media.inset_fill) then color(track, t.sunken) end; setBorder(self, t.edge, t.border)
    if not Shade:HasFile(Shade.media.slider_thumb) then th:SetVertexColor(t.text[1], t.text[2], t.text[3], 1) end
  end
  return s
end

-- DROPDOWN ------------------------------------------------------------------
function W.Dropdown(parent, width)
  local d = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate"); d:SetSize(width or 160, 24)
  local bg = d:CreateTexture(nil, "BACKGROUND"); bg:SetPoint("TOPLEFT", 16, -2); bg:SetPoint("BOTTOMRIGHT", -18, 2)
  if Shade:HasFile(Shade.media.inset_fill) then bg:SetTexture(Shade.media.inset_fill) else color(bg, Shade.theme.sunken) end
  setBorder(d, Shade.theme.edge, Shade.theme.border)

  if Shade:HasFile(Shade.media.dropdown_arrow) then
    local ar = d:CreateTexture(nil, "ARTWORK"); ar:SetSize(14,14); ar:SetPoint("RIGHT", -4, 0); ar:SetTexture(Shade.media.dropdown_arrow); d.__arrow = ar
  end

  function d:ApplyTheme(t)
    if not Shade:HasFile(Shade.media.inset_fill) then color(bg, t.sunken) end
    setBorder(self, t.edge, t.border)
  end
  return d
end

-- SCROLLBAR -----------------------------------------------------------------
function W.SkinScrollBar(sb)
  if not sb then return end
  local track = sb.__track or sb:CreateTexture(nil, "BACKGROUND"); sb.__track = track
  track:ClearAllPoints(); track:SetPoint("TOPLEFT", 2, -2); track:SetPoint("BOTTOMRIGHT", -2, 2)
  if Shade:HasFile(Shade.media.scroll_track) then track:SetTexture(Shade.media.scroll_track) else color(track, Shade.theme.sunken) end
  local thumb = sb:GetThumbTexture() or sb:CreateTexture(nil, "ARTWORK")
  if Shade:HasFile(Shade.media.scroll_thumb) then thumb:SetTexture(Shade.media.scroll_thumb) else thumb:SetTexture(WHITE); thumb:SetVertexColor(Shade.theme.text[1],Shade.theme.text[2],Shade.theme.text[3],1) end
  sb:SetThumbTexture(thumb)
  setBorder(sb, Shade.theme.edge, Shade.theme.border)
end

-- TABS ----------------------------------------------------------------------
function W.Tab(parent, text, width)
  local t = CreateFrame("Button", nil, parent, "BackdropTemplate"); t:SetSize(width or 120, 24)
  local bg = t:CreateTexture(nil, "BACKGROUND")
  if Shade:HasFile(Shade.media.tab_inactive) then bg:SetTexture(Shade.media.tab_inactive); bg:SetHorizTile(true) else color(bg, Shade.theme.raised) end
  setBorder(t, Shade.theme.edge, Shade.theme.border)
  local fs = t:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); fs:SetPoint("CENTER"); fs:SetText(text or "Tab"); fs:SetTextColor(Shade.theme.text[1],Shade.theme.text[2],Shade.theme.text[3],1)
  t.__bg, t.__fs = bg, fs
  function t:SetActive(active)
    if active and Shade:HasFile(Shade.media.tab_active) then t.__bg:SetTexture(Shade.media.tab_active) elseif Shade:HasFile(Shade.media.tab_inactive) then t.__bg:SetTexture(Shade.media.tab_inactive) end
  end
  function t:ApplyTheme(T) if not Shade:HasFile(Shade.media.tab_inactive) then color(bg, T.raised) end; setBorder(self, T.edge, T.border); fs:SetTextColor(T.text[1],T.text[2],T.text[3],1) end
  return t
end

-- Dropdown list skinning -----------------------------------------------------
local function StyleListButton(b)
  if not b then return end
  if b.Highlight then b.Highlight:SetTexture(WHITE); b.Highlight:SetVertexColor(Shade.theme.focus[1], Shade.theme.focus[2], Shade.theme.focus[3], Shade.theme.focus[4]) end
  if b.Check then b.Check:SetVertexColor(1,1,1,1) end
  if b.UnCheck then b.UnCheck:SetVertexColor(0,0,0,0) end
  local fs = b:GetFontString() or b.NormalText or _G[b:GetName() and (b:GetName().."NormalText") or ""]
  if fs then fs:SetTextColor(Shade.theme.text[1], Shade.theme.text[2], Shade.theme.text[3], 1) end
end

local function SkinDropdownList(level)
  level = level or 1
  for L = 1, (level + 2) do
    local list = _G["DropDownList"..L]
    if list and not list.__shadeSkinned then
      list.__shadeSkinned = true
      local bg = list:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
      if Shade:HasFile(Shade.media.inset_fill) then bg:SetTexture(Shade.media.inset_fill) else color(bg, Shade.theme.raised) end
      setBorder(list, Shade.theme.edge, Shade.theme.border)
      local sb = _G["DropDownList"..L.."ScrollBar"]; if sb then W.SkinScrollBar(sb) end
    end
    if list then for i = 1, (UIDROPDOWNMENU_MAXBUTTONS or 50) do StyleListButton(_G["DropDownList"..L.."Button"..i]) end end
  end
end
hooksecurefunc("ToggleDropDownMenu", function(level) SkinDropdownList(level) end)

-- THEME PROP -----------------------------------------------------------------
function UI:ApplyTheme(t)
  local root = self.Root; if not root then return end
  if root.ApplyTheme then root:ApplyTheme(t) end
  for _, child in ipairs(root.__themeChildren or {}) do if child.ApplyTheme then child:ApplyTheme(t) end end
  SkinDropdownList(UIDROPDOWNMENU_MAXLEVELS or 2)
end
