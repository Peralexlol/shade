-- File: Shade/ui/Widgets.lua
-- Save as UTF-8 (no BOM). ASCII-only to avoid parser issues.
-- Why: Provides Shade.UI.Widgets and fixes "unexpected symbol near 'local'".

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

Shade.UI = Shade.UI or {}
local W = {}
Shade.UI.Widgets = W

W.__VERSION = "0.2.3"

-- Theme palette (subtle dark with purple accent)
local TONE_WINDOW = {0.07, 0.075, 0.085, 0.98}
local TONE_CANVAS = {0.09, 0.10, 0.12, 0.98}
local TONE_GROUP  = {0.11, 0.12, 0.14, 0.96}
local ACCENT      = {0.50, 0.35, 0.95, 1.00}  -- #8059F2
local SUI_YELLOW  = {1.00, 0.82, 0.00, 1.00}

local MEDIA_PATH  = "Interface\\AddOns\\Shade\\media\\"

local function applyBackground(frame, tone)
  local r,g,b,a = unpack(tone or TONE_CANVAS)
  if not frame.__bg then
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetAllPoints(true)
    frame.__bg = bg
  end
  frame.__bg:SetColorTexture(r,g,b,a)

  if not frame.__noise then
    local t = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    t:SetAllPoints(true)
    t:SetTexture(MEDIA_PATH.."noise.tga")
    t:SetAlpha(0.08)
    frame.__noise = t
  end

  if not frame.__stripe then
    local t = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
    t:SetAllPoints(true)
    t:SetTexture(MEDIA_PATH.."stripe.tga")
    t:SetAlpha(0.05)
    frame.__stripe = t
  end
end

local function makeHairline(parent, yOff)
  local t = parent:CreateTexture(nil, "BORDER")
  t:SetHeight(1)
  t:SetPoint("LEFT", 6, yOff or 0)
  t:SetPoint("RIGHT", -6, yOff or 0)
  t:SetTexture(MEDIA_PATH.."accent_line.tga")
  t:SetAlpha(0.7)
  return t
end

-- Public constructors -------------------------------------------------------

function W.Frame(parent, name, width, height)
  local f = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetSize(width or 400, height or 300)
  applyBackground(f, TONE_CANVAS)
  return f
end

function W.Section(parent, label)
  local box = CreateFrame("Frame", nil, parent)
  box:SetSize(10, 10)
  applyBackground(box, TONE_GROUP)

  local header = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  header:SetPoint("TOPLEFT", 10, -8)
  header:SetText(label or "Section")

  makeHairline(box, -24)
  box._header = header
  return box
end

function W.Button(parent, label, width, height)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width or 100, height or 24)
  b:SetText(label or "Button")
  -- Why: Remove default art so our background shows through
  if b.Left then b.Left:SetAlpha(0) end
  if b.Middle then b.Middle:SetAlpha(0) end
  if b.Right then b.Right:SetAlpha(0) end
  if b.SetNormalTexture then b:SetNormalTexture(nil) end
  if b.SetPushedTexture then b:SetPushedTexture(nil) end
  if b.SetHighlightTexture then b:SetHighlightTexture(nil) end

  applyBackground(b, TONE_GROUP)
  local hl = b:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints(true)
  hl:SetColorTexture(1,1,1,0.08)
  return b
end

function W.Input(parent, width)
  local holder = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  holder:SetSize(width or 180, 28)
  applyBackground(holder, TONE_WINDOW)

  local edit = CreateFrame("EditBox", nil, holder)
  edit:SetAutoFocus(false)
  edit:SetFontObject("GameFontHighlight")
  edit:SetPoint("LEFT", 8, 0)
  edit:SetPoint("RIGHT", -8, 0)
  edit:SetHeight(20)
  edit:SetTextInsets(2,2,2,2)

  holder.EditBox = edit
  return holder
end

function W.Checkbox(parent, label)
  local cb = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
  cb:SetSize(20, 20)
  -- Why: Use flat square and yellow tick for clarity
  if cb.SetNormalTexture then cb:SetNormalTexture(nil) end
  if cb.SetPushedTexture then cb:SetPushedTexture(nil) end
  if cb.SetHighlightTexture then cb:SetHighlightTexture(nil) end
  if cb.SetCheckedTexture then cb:SetCheckedTexture(nil) end

  local box = cb:CreateTexture(nil, "ARTWORK")
  box:SetAllPoints(true)
  box:SetColorTexture(unpack(TONE_GROUP))

  local tick = cb:CreateTexture(nil, "OVERLAY")
  tick:SetPoint("CENTER")
  tick:SetSize(12, 12)
  tick:SetColorTexture(unpack(SUI_YELLOW))
  tick:Hide()

  cb:HookScript("OnClick", function(self)
    if self:GetChecked() then tick:Show() else tick:Hide() end
  end)

  local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("LEFT", cb, "RIGHT", 8, 0)
  fs:SetText(label or "")
  cb.Label = fs

  return cb
end

local function attachSliderThumb(slider)
  if slider.__thumb then return end
  local t = slider:CreateTexture(nil, "ARTWORK")
  t:SetSize(12, 12)
  t:SetColorTexture(unpack(ACCENT))
  slider:SetThumbTexture(t)
  slider.__thumb = t
end

function W.Slider(parent, minVal, maxVal, step)
  local template = (C_XMLUtil and "MinimalSliderWithSteppersTemplate") or "OptionsSliderTemplate"
  local s = CreateFrame("Slider", nil, parent, template)
  s:SetMinMaxValues(minVal or 0, maxVal or 100)
  s:SetValueStep(step or 1)
  s:SetObeyStepOnDrag(true)
  s:SetSize(180, 20)
  attachSliderThumb(s)

  if s.Low then s.Low:SetText(tostring(minVal or 0)) end
  if s.High then s.High:SetText(tostring(maxVal or 100)) end
  if s.Text then s.Text:SetText("") end

  return s
end

function W.CloseButton(parent, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(18, 18)
  applyBackground(b, TONE_GROUP)

  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("CENTER")
  fs:SetText("x")

  b:SetScript("OnClick", function()
    if type(onClick) == "function" then onClick() else parent:Hide() end
  end)
  return b
end

-- Utility
function W.Verify()
  return W.__VERSION
end
