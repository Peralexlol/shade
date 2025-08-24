--[=[
File: ui/Widgets.lua (v0.2.3)
Why: User reported no visual change. This build:
- Keeps SUI-styled widgets (dropdown field, checkboxes, sliders, inputs, tabs).
- Ensures a **visible purple thumb** on sliders.
- Uses a **custom flat close button** with an "x".
- Adds a tiny version flag (W.__VERSION) to verify the file actually loaded.
No logic changes.
]=]

local ADDON = ...
local Shade = _G.Shade
local media = Shade.media

-- Absolute media paths
local BASE = 'Interface/AddOns/'..tostring(ADDON)..'/'
local function path(p, fallback)
  if type(p) == 'string' and p:find('Interface/AddOns', 1, true) then return p end
  return BASE..(fallback or '')
end
media.noise        = path(media.noise,        'media/noise.tga')
media.stripe       = path(media.stripe,       'media/stripe.tga')
media.font         = path(media.font,         'media/fonts/Oxanium-ExtraBold.ttf')
media.header_strip = path(media.header_strip, 'media/header_strip.tga')
media.accent_line  = path(media.accent_line,  'media/accent_line.tga')

-- SUI tones
local ACCENT = {0.50, 0.35, 0.95, 1.00}
local YCHECK = {1.00, 0.82, 0.00, 1.00}
local TONE_WINDOW = {0.07, 0.075, 0.085, 0.98}
local TONE_CANVAS = {0.09, 0.10, 0.12, 0.98}
local TONE_GROUP  = {0.11, 0.12, 0.14, 0.96}
local TONE_BTN    = {0.16, 0.17, 0.20, 0.96}
local BORDER_DARK = {0,0,0,0.90}
local HAIRLINE    = {1,1,1,0.08}

local W = { __VERSION = '0.2.3' }

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function Unsnap(tex)
  if tex and tex.SetSnapToPixelGrid then tex:SetSnapToPixelGrid(false) end
  if tex and tex.SetTexelSnappingBias then tex:SetTexelSnappingBias(0.0) end
end

local function SetFontSafe(fs, path, size)
  if not fs then return end
  local ok = false
  if type(path) == 'string' and path ~= '' then ok = fs:SetFont(path, size, '') end
  if not ok then fs:SetFont(STANDARD_TEXT_FONT, size, '') end
  fs:SetTextColor(1,1,1,1)
end

local function SkinFlat(frame, color)
  if frame.SetBackdrop then
    frame:SetBackdrop({ bgFile='Interface/Buttons/WHITE8x8', edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
    frame:SetBackdropColor(unpack(color))
    frame:SetBackdropBorderColor(unpack(BORDER_DARK))
  else
    local bg = frame.__shade_bg or frame:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints(); bg:SetColorTexture(unpack(color)); frame.__shade_bg = bg
  end
end

local function HideAllTextures(frame)
  if not frame then return end
  local r = {frame:GetRegions()}
  for i=1,#r do if r[i].GetObjectType and r[i]:GetObjectType()=="Texture" then r[i]:SetAlpha(0) end end
end

---------------------------------------------------------------------
-- Windows
---------------------------------------------------------------------
function W.Frame(parent, w, h)
  local f = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  f:SetSize(w or 960, h or 560)
  SkinFlat(f, TONE_WINDOW)
  local top = f:CreateTexture(nil, 'BORDER'); top:SetPoint('TOPLEFT',1,-1); top:SetPoint('TOPRIGHT',-1,-1); top:SetHeight(1); top:SetColorTexture(unpack(HAIRLINE))
  return f
end

function W.Header(parent, text)
  local h = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  h:SetPoint('TOPLEFT', 8, -8); h:SetPoint('TOPRIGHT', -8, -8); h:SetHeight(28)
  local strip = h:CreateTexture(nil, 'BACKGROUND'); strip:SetAllPoints(); strip:SetTexture(media.header_strip); strip:SetAlpha(0.06)
  local underline = h:CreateTexture(nil, 'OVERLAY'); underline:SetPoint('BOTTOMLEFT'); underline:SetPoint('BOTTOMRIGHT'); underline:SetHeight(2); underline:SetTexture(media.accent_line); underline:SetVertexColor(ACCENT[1],ACCENT[2],ACCENT[3],0.85)
  local fs = h:CreateFontString(nil, 'OVERLAY'); fs:SetPoint('LEFT', 10, -1); SetFontSafe(fs, media.font, 20); fs:SetText(text or 'Shade — Settings'); h.title = fs
  return h
end

-- SUI-style close button
function W.Close(parent)
  local b = CreateFrame('Button', nil, parent, 'BackdropTemplate')
  b:SetSize(20,20)
  SkinFlat(b, TONE_BTN)
  local x = b:CreateFontString(nil, 'OVERLAY'); SetFontSafe(x, media.font, 14); x:SetPoint('CENTER'); x:SetText('x'); b.label = x
  local hl = b:CreateTexture(nil, 'HIGHLIGHT'); hl:SetAllPoints(); hl:SetColorTexture(1,1,1,0.08)
  b:SetScript('OnClick', function() parent:Hide() end)
  return b
end

---------------------------------------------------------------------
-- Groups/Buttons/Tabs
---------------------------------------------------------------------
function W.Section(parent, title)
  local g = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  SkinFlat(g, TONE_GROUP)
  local fs = g:CreateFontString(nil, 'OVERLAY'); fs:SetPoint('TOPLEFT', 14, -12); SetFontSafe(fs, media.font, 16); fs:SetText(title or 'Group'); g.title=fs
  local div = g:CreateTexture(nil, 'ARTWORK'); div:SetPoint('TOPLEFT', 10, -28); div:SetPoint('TOPRIGHT', -10, -28); div:SetHeight(1); div:SetColorTexture(unpack(HAIRLINE)); Unsnap(div)
  return g
end

function W.Button(parent, label, w, h)
  local b = CreateFrame('Button', nil, parent, 'BackdropTemplate')
  b:SetSize(w or 120, h or 28)
  local fill = b:CreateTexture(nil, 'BACKGROUND'); fill:SetAllPoints(); fill:SetColorTexture(unpack(TONE_BTN))
  local hover = b:CreateTexture(nil, 'HIGHLIGHT'); hover:SetAllPoints(); hover:SetColorTexture(1,1,1,0.06)
  if b.SetBackdrop then b:SetBackdrop({ edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1 }); b:SetBackdropBorderColor(ACCENT[1],ACCENT[2],ACCENT[3],1) end
  local fs = b:CreateFontString(nil, 'OVERLAY'); fs:SetPoint('CENTER'); SetFontSafe(fs, media.font, 16); fs:SetText(label or 'Button'); b.text=fs
  return b
end

function W.Tab(parent, label)
  local t = CreateFrame('Button', nil, parent, 'BackdropTemplate')
  t:SetSize(120, 26)
  local fill = t:CreateTexture(nil, 'BACKGROUND'); fill:SetAllPoints(); fill:SetColorTexture(0.11,0.12,0.14,0.96); t.fill=fill
  local top = t:CreateTexture(nil, 'OVERLAY'); top:SetPoint('TOPLEFT',0,0); top:SetPoint('TOPRIGHT',0,0); top:SetHeight(2); top:SetTexture(media.accent_line); top:SetVertexColor(ACCENT[1],ACCENT[2],ACCENT[3],0.95); t.topline=top
  local fs = t:CreateFontString(nil, 'OVERLAY'); fs:SetPoint('CENTER'); SetFontSafe(fs, media.font, 15); fs:SetText(label or 'Tab'); t.label=fs
  t:SetScript('OnEnter', function() fill:SetColorTexture(0.15,0.16,0.18,0.96) end)
  t:SetScript('OnLeave', function() fill:SetColorTexture(0.11,0.12,0.14,0.96) end)
  return t
end

---------------------------------------------------------------------
-- Form Controls (SUI-like)
---------------------------------------------------------------------
function W.Dropdown(parent, width)
  local d = CreateFrame('Frame', nil, parent, 'UIDropDownMenuTemplate')
  d:SetWidth(width or 180)
  HideAllTextures(d)
  local box = CreateFrame('Frame', nil, d, 'BackdropTemplate')
  box:SetPoint('TOPLEFT', 16, -2)
  box:SetPoint('BOTTOMRIGHT', -16, 8)
  SkinFlat(box, TONE_BTN)
  local chev = box:CreateTexture(nil, 'OVERLAY'); chev:SetPoint('RIGHT', -6, 0); chev:SetSize(8,2); chev:SetTexture(media.accent_line); chev:SetVertexColor(ACCENT[1],ACCENT[2],ACCENT[3],0.9)
  return d
end

function W.Check(parent, label)
  local cb = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
  -- DF-safe: make default art transparent
  local tex
  tex = cb.GetNormalTexture and cb:GetNormalTexture();    if tex then tex:SetTexture('Interface/Buttons/WHITE8x8');   tex:SetAlpha(0) end
  tex = cb.GetPushedTexture and cb:GetPushedTexture();     if tex then tex:SetTexture('Interface/Buttons/WHITE8x8');   tex:SetAlpha(0) end
  tex = cb.GetHighlightTexture and cb:GetHighlightTexture(); if tex then tex:SetTexture('Interface/Buttons/WHITE8x8'); tex:SetAlpha(0.06) end
  tex = cb.GetCheckedTexture and cb:GetCheckedTexture();   if tex then tex:SetTexture('Interface/Buttons/WHITE8x8');   tex:SetAlpha(0) end

  local box = CreateFrame('Frame', nil, cb, 'BackdropTemplate')
  box:SetPoint('LEFT')
  box:SetSize(18,18)
  SkinFlat(box, TONE_BTN)
  if box.SetBackdropBorderColor then box:SetBackdropBorderColor(unpack(HAIRLINE)) end

  local fill = box:CreateTexture(nil, 'ARTWORK')
  fill:SetPoint('TOPLEFT', 3, -3); fill:SetPoint('BOTTOMRIGHT', -3, 3)
  fill:SetColorTexture(unpack(YCHECK)); fill:Hide()

  local function update()
    if cb:GetChecked() then fill:Show() else fill:Hide() end
  end
  cb:HookScript('OnClick', update)
  cb:HookScript('OnShow', update)

  local fs = cb.Text or cb.text or cb:CreateFontString(nil, 'OVERLAY')
  fs:SetPoint('LEFT', box, 'RIGHT', 6, 0)
  SetFontSafe(fs, media.font, 16)
  fs:SetText(label or '')
  cb.Text = fs
  return cb
end

function W.Slider(parent, label, min, max, step, width)
  local s = CreateFrame('Slider', nil, parent, 'OptionsSliderTemplate')
  s:SetMinMaxValues(min, max)
  s:SetValueStep(step or 1)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(width or 260)
  s:EnableMouse(true)
  HideAllTextures(s)

  local track = s:CreateTexture(nil, 'BACKGROUND')
  track:SetPoint('TOPLEFT', 2, -10)
  track:SetPoint('TOPRIGHT', -2, -10)
  track:SetHeight(2)
  track:SetColorTexture(1,1,1,0.10)

  local th = s:GetThumbTexture(); if not th then th = s:CreateTexture() end
  th:SetDrawLayer('OVERLAY')
  th:SetTexture('Interface/Buttons/WHITE8x8')
  th:SetColorTexture(ACCENT[1],ACCENT[2],ACCENT[3], 1)
  th:SetSize(12, 20)
  s:SetThumbTexture(th)

  local textFS = s.Text or (s.GetName and s:GetName() and _G[s:GetName()..'Text'])
  local lowFS  = s.Low  or (s.GetName and s:GetName() and _G[s:GetName()..'Low'])
  local highFS = s.High or (s.GetName and s:GetName() and _G[s:GetName()..'High'])
  if textFS then SetFontSafe(textFS, media.font, 15); textFS:SetText(label or '') end
  if lowFS  then SetFontSafe(lowFS,  media.font, 12); lowFS:SetText(tostring(min)) end
  if highFS then SetFontSafe(highFS, media.font, 12); highFS:SetText(tostring(max)) end

  return s
end

function W.Input(parent, width)
  local eb = CreateFrame('EditBox', nil, parent, 'BackdropTemplate')
  eb:SetAutoFocus(false)
  eb:SetSize(width or 240, 24)
  SetFontSafe(eb, media.font, 14)
  SkinFlat(eb, TONE_BTN)
  eb:SetTextInsets(6,6,2,2)
  return eb
end

function W.EditBoxMultiline(parent, w, h)
  local sf = CreateFrame('ScrollFrame', nil, parent, 'UIPanelScrollFrameTemplate')
  sf:SetSize(w or 600, h or 140)
  local edit = CreateFrame('EditBox', nil, sf, 'BackdropTemplate')
  edit:SetMultiLine(true); edit:SetAutoFocus(false); SetFontSafe(edit, media.font, 13)
  edit:SetWidth(w or 600); edit:SetHeight(h or 140)
  SkinFlat(edit, TONE_BTN)
  sf:SetScrollChild(edit)
  local sb = sf.ScrollBar
  if sb then
    HideAllTextures(sb)
    local track = sb:CreateTexture(nil, 'BACKGROUND'); track:SetAllPoints(); track:SetColorTexture(0,0,0,0.25)
    local th = sb.ThumbTexture or sb:GetThumbTexture() or sb:CreateTexture()
    th:SetTexture('Interface/Buttons/WHITE8x8'); th:SetColorTexture(1,1,1,0.9); th:SetWidth(8)
    sb:SetThumbTexture(th)
  end
  sf.edit = edit
  return sf
end

---------------------------------------------------------------------
-- Canvas (center area)
---------------------------------------------------------------------
function W.Canvas(parent)
  local c = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  SkinFlat(c, TONE_CANVAS)
  local stripe = c:CreateTexture(nil, 'BACKGROUND'); stripe:SetAllPoints(); stripe:SetTexture(media.stripe, 'REPEAT', 'REPEAT'); stripe:SetAlpha(0.015); Unsnap(stripe)
  local noise  = c:CreateTexture(nil, 'BACKGROUND'); noise:SetAllPoints();  noise:SetTexture(media.noise,  'REPEAT', 'REPEAT');  noise:SetAlpha(0.02);  Unsnap(noise)
  local ib = c:CreateTexture(nil, 'BORDER'); ib:SetPoint('TOPLEFT', 1, -1); ib:SetPoint('BOTTOMRIGHT', -1, 1); ib:SetColorTexture(unpack(HAIRLINE))
  return c
end

Shade.UI = Shade.UI or {}
Shade.UI.Widgets = W
