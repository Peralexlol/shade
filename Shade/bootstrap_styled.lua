-- File: Shade/bootstrap_styled.lua
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- One-file, styled UI with slash commands. Bypasses separate widgets/config files.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

-- Theme (solid colors; overlays optional)
Shade.Theme = Shade.Theme or {
  tone_window = {0.07, 0.075, 0.085, 1.00},
  tone_canvas = {0.09, 0.10, 0.12, 1.00},
  tone_group  = {0.12, 0.13, 0.16, 1.00},
  accent      = {0.50, 0.35, 0.95, 1.00},
  tick        = {1.00, 0.82, 0.00, 1.00},
}

local T = Shade.Theme
local MEDIA_PATH = "Interface\\AddOns\\Shade\\media\\"

-- Helpers -----------------------------------------------------------
local function setFillTex(frame, tone, layer, subLayer)
  local r,g,b,a = unpack(tone)
  local tex = frame:CreateTexture(nil, layer or "BACKGROUND", nil, subLayer or 0)
  tex:SetAllPoints(true)
  tex:SetColorTexture(r,g,b,a)
  return tex
end

local function tryOverlay(frame, filename, alpha, layer, subLayer)
  local tex = frame:CreateTexture(nil, layer or "BACKGROUND", nil, subLayer or 1)
  tex:SetAllPoints(true)
  tex:SetTexture(MEDIA_PATH..filename)
  if alpha then tex:SetAlpha(alpha) end
  return tex
end

local function applyPanelStyle(frame, tone)
  if frame.__styled then return end
  frame.__bg = setFillTex(frame, tone or T.tone_canvas, "BACKGROUND", -8)
  frame.__noise = tryOverlay(frame, "noise.tga", 0.08, "BACKGROUND", -7)
  frame.__stripe = tryOverlay(frame, "stripe.tga", 0.05, "BACKGROUND", -6)
  frame.__styled = true
end

local function hairline(parent, y)
  local t = parent:CreateTexture(nil, "BORDER", nil, 0)
  t:SetHeight(1)
  t:SetPoint("LEFT", 6, y or 0)
  t:SetPoint("RIGHT", -6, y or 0)
  t:SetColorTexture(1,1,1,0.07)
  return t
end

-- Widgets ----------------------------------------------------------
Shade.UI = Shade.UI or {}
local W = {}
Shade.UI.Widgets = W
W.__VERSION = "0.2.5"

function W.Frame(parent, name, width, height)
  local f = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetSize(width or 520, height or 380)
  applyPanelStyle(f, T.tone_canvas)
  return f
end

function W.Window(parent, name, width, height)
  local f = W.Frame(parent, name, width or 520, height or 380)
  applyPanelStyle(f, T.tone_window)
  return f
end

function W.Section(parent, label)
  local box = CreateFrame("Frame", nil, parent)
  box:SetSize(10, 10)
  applyPanelStyle(box, T.tone_group)

  local header = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  header:SetPoint("TOPLEFT", 10, -8)
  header:SetText(label or "Section")

  hairline(box, -24)
  box._header = header
  return box
end

function W.Button(parent, label, width, height)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width or 100, height or 24)
  b:SetText(label or "Button")
  if b.Left then b.Left:SetAlpha(0) end
  if b.Middle then b.Middle:SetAlpha(0) end
  if b.Right then b.Right:SetAlpha(0) end
  if b.SetNormalTexture then b:SetNormalTexture(nil) end
  if b.SetPushedTexture then b:SetPushedTexture(nil) end
  if b.SetHighlightTexture then b:SetHighlightTexture(nil) end
  applyPanelStyle(b, T.tone_group)
  local hl = b:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints(true)
  hl:SetColorTexture(1,1,1,0.08)
  return b
end

function W.Input(parent, width)
  local holder = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  holder:SetSize(width or 180, 28)
  applyPanelStyle(holder, T.tone_window)
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
  local box = cb:CreateTexture(nil, "ARTWORK")
  box:SetAllPoints(true)
  local r,g,b,a = unpack(T.tone_group)
  box:SetColorTexture(r,g,b,a)
  local tick = cb:CreateTexture(nil, "OVERLAY")
  tick:SetPoint("CENTER")
  tick:SetSize(12, 12)
  tick:SetColorTexture(unpack(T.tick))
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
  t:SetColorTexture(unpack(T.accent))
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
  applyPanelStyle(b, T.tone_group)
  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("CENTER")
  fs:SetText("x")
  b:SetScript("OnClick", function()
    if type(onClick) == "function" then onClick() else parent:Hide() end
  end)
  return b
end

function W.Verify() return W.__VERSION end

-- Config UI --------------------------------------------------------
local UI
local function EnsureUI()
  if UI and UI.__built then return true end
  UI = W.Window(UIParent, "ShadeConfig", 520, 380)
  UI:Hide()

  local title = UI:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", 14, -12)
  title:SetText("Shade - Settings")

  local close = W.CloseButton(UI)
  close:SetPoint("TOPRIGHT", -10, -10)

  local general = W.Section(UI, "General")
  general:SetPoint("TOPLEFT", 12, -40)
  general:SetPoint("RIGHT", -12, 0)
  general:SetHeight(120)

  local enableCB = W.Checkbox(general, "Enable Blizzard skin")
  enableCB:SetPoint("TOPLEFT", general, "TOPLEFT", 12, -36)
  enableCB:SetChecked(true)

  local profiles = W.Section(UI, "Profiles")
  profiles:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -12)
  profiles:SetPoint("RIGHT", -12, 0)
  profiles:SetHeight(120)

  local nameField = W.Input(profiles, 240)
  nameField:SetPoint("TOPLEFT", profiles, "TOPLEFT", 12, -36)
  nameField.EditBox:SetText("Default")

  local save = W.Button(profiles, "Save", 80, 24)
  save:SetPoint("LEFT", nameField, "RIGHT", 12, 0)
  save:SetScript("OnClick", function()
    print("|cff8059f2Shade|r: Saved profile '"..(nameField.EditBox:GetText() or "").."'.")
  end)

  UI.__built = true
  return true
end

function Shade.ToggleConfig()
  local ok = EnsureUI()
  if not ok then return end
  if UI:IsShown() then UI:Hide() else UI:Show() end
end

-- Slash ------------------------------------------------------------
SLASH_SHADE1 = "/shade"
SLASH_SHADE2 = "/sui"
SlashCmdList.SHADE = function(msg)
  msg = (msg or ""):lower()
  if msg == "debug" then
    print("|cff8059f2Shade|r debug:")
    print("  Widgets version:", W.Verify())
    print("  Config built:", UI and UI.__built and true or false)
  else
    Shade.ToggleConfig()
  end
end
