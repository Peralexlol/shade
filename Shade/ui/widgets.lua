-- File: Shade/ui/widgets.lua (compat v0.3.1 – widgets + dropdown + closebutton)
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- Stable, styled widgets; guarded setters; adds Dropdown, Separator, CloseButton.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

Shade.Theme = Shade.Theme or {
  tone_window = {0.07, 0.075, 0.085, 1.00},
  tone_canvas = {0.09, 0.10, 0.12, 1.00},
  tone_group  = {0.12, 0.13, 0.16, 1.00},
  accent      = {0.50, 0.35, 0.95, 1.00},
  tick        = {1.00, 0.82, 0.00, 1.00},
}
local T = Shade.Theme
local MEDIA = "Interface\\AddOns\\Shade\\media\\"

local function fill(frame, color, layer, sublvl)
  local r,g,b,a = unpack(color)
  local t = frame:CreateTexture(nil, layer or "BACKGROUND", nil, sublvl or 0)
  t:SetAllPoints(true)
  t:SetColorTexture(r,g,b,a)
  return t
end

local function tryOverlay(frame, name, alpha, layer, sublvl)
  local t = frame:CreateTexture(nil, layer or "BACKGROUND", nil, sublvl or 1)
  t:SetAllPoints(true)
  t:SetTexture(MEDIA..name)
  if alpha then t:SetAlpha(alpha) end
  return t
end

local function stylePanel(frame, color)
  if frame.__styled then return end
  frame.__bg     = fill(frame, color or T.tone_canvas, "BACKGROUND", -8)
  frame.__noise  = tryOverlay(frame, "noise.tga", 0.08, "BACKGROUND", -7)
  frame.__stripe = tryOverlay(frame, "stripe.tga", 0.05, "BACKGROUND", -6)
  frame.__styled = true
end

local function guardSetters(obj)
  local function wrap(method)
    local orig = obj[method]
    if type(orig) ~= "function" then return end
    obj[method] = function(self, asset)
      local ty = type(asset)
      if asset == nil or ty == "string" or ty == "userdata" then
        return orig(self, asset)
      end
      if not self.__shade_tex_warned then
        print("|cff8059f2Shade|r: Ignored invalid "..method.." arg type '"..ty.."'.")
        self.__shade_tex_warned = true
      end
    end
  end
  wrap("SetNormalTexture"); wrap("SetPushedTexture"); wrap("SetHighlightTexture"); wrap("SetCheckedTexture")
end

local function hideStateTextures(btn)
  local getters = { btn.GetNormalTexture, btn.GetPushedTexture, btn.GetHighlightTexture, btn.GetCheckedTexture }
  for _, getter in ipairs(getters) do
    if type(getter) == "function" then
      local tex = getter(btn)
      if tex and tex.SetAlpha then tex:SetAlpha(0) end
    end
  end
end

-- Public API -------------------------------------------------------
Shade.UI = Shade.UI or {}
local W = {}
Shade.UI.Widgets = W

W.__VERSION = "0.3.1"

function W.Frame(parent, name, width, height)
  local f = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetSize(width or 520, height or 380)
  stylePanel(f, T.tone_canvas)
  return f
end

function W.Window(parent, name, width, height)
  local f = W.Frame(parent, name, width or 520, height or 380)
  stylePanel(f, T.tone_window)
  -- accent bar on top
  local ab = f:CreateTexture(nil, "BORDER")
  ab:SetPoint("TOPLEFT", 8, -28)
  ab:SetPoint("TOPRIGHT", -8, -28)
  ab:SetHeight(2)
  local r,g,b,a = unpack(T.accent)
  ab:SetColorTexture(r,g,b,a or 1)
  f.__accent = ab
  return f
end

function W.Separator(parent, y)
  local t = parent:CreateTexture(nil, "BORDER")
  t:SetPoint("LEFT", 12, y or 0)
  t:SetPoint("RIGHT", -12, y or 0)
  t:SetHeight(1)
  t:SetColorTexture(1,1,1,0.08)
  return t
end

function W.Section(parent, label)
  local box = CreateFrame("Frame", nil, parent)
  box:SetSize(10, 10)
  stylePanel(box, T.tone_group)

  local header = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  header:SetPoint("TOPLEFT", 10, -8)
  header:SetText(label or "Section")

  W.Separator(box, -24)
  box._header = header
  return box
end

function W.Button(parent, label, width, height)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width or 100, height or 24)
  b:SetText(label or "Button")
  guardSetters(b); hideStateTextures(b)
  stylePanel(b, T.tone_group)
  local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(true); hl:SetColorTexture(1,1,1,0.08)
  return b
end

function W.CloseButton(parent, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(18, 18)
  guardSetters(b); hideStateTextures(b)
  stylePanel(b, T.tone_group)
  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("CENTER"); fs:SetText("x")
  b:SetScript("OnClick", function()
    if type(onClick) == "function" then onClick() else parent:Hide() end
  end)
  return b
end

function W.Input(parent, width)
  local holder = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  holder:SetSize(width or 220, 28)
  stylePanel(holder, T.tone_window)
  local edit = CreateFrame("EditBox", nil, holder)
  edit:SetAutoFocus(false); edit:SetFontObject("GameFontHighlight")
  edit:SetPoint("LEFT", 8, 0); edit:SetPoint("RIGHT", -8, 0); edit:SetHeight(20); edit:SetTextInsets(2,2,2,2)
  holder.EditBox = edit
  return holder
end

function W.Check(parent, label)
  local cb = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
  cb:SetSize(20, 20)
  guardSetters(cb); hideStateTextures(cb)
  local box = cb:CreateTexture(nil, "ARTWORK", nil, 0)
  local r,g,b,a = unpack(T.tone_group); box:SetAllPoints(true); box:SetColorTexture(r,g,b,a)
  local tick = cb:CreateTexture(nil, "OVERLAY", nil, 1)
  tick:SetPoint("CENTER"); tick:SetSize(12, 12); tick:SetColorTexture(unpack(T.tick)); tick:Hide()
  cb:HookScript("OnClick", function(self) if self:GetChecked() then tick:Show() else tick:Hide() end end)
  local fs = cb.Text or cb.text or cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:ClearAllPoints(); fs:SetPoint("LEFT", cb, "RIGHT", 8, 0); fs:SetText(label or ""); cb.Label = fs
  return cb
end
W.Checkbox = W.Check

local function sliderThumb(slider)
  if slider.__thumb then return end
  local t = slider:CreateTexture(nil, "ARTWORK")
  t:SetSize(12, 12); t:SetColorTexture(unpack(T.accent))
  slider:SetThumbTexture(t); slider.__thumb = t
end

function W.Slider(parent, minVal, maxVal, step)
  local template = (C_XMLUtil and "MinimalSliderWithSteppersTemplate") or "OptionsSliderTemplate"
  local s = CreateFrame("Slider", nil, parent, template)
  s:SetMinMaxValues(minVal or 0, maxVal or 100); s:SetValueStep(step or 1); s:SetObeyStepOnDrag(true); s:SetSize(200, 18)
  sliderThumb(s)
  if s.Low then s.Low:SetText(tostring(minVal or 0)) end
  if s.High then s.High:SetText(tostring(maxVal or 100)) end
  if s.Text then s.Text:SetText("") end
  return s
end

-- Simple dropdown --------------------------------------------------
function W.Dropdown(parent, width, options, onSelect)
  local dd = CreateFrame("Frame", nil, parent)
  dd:SetSize(width or 180, 26)
  stylePanel(dd, T.tone_window)

  local label = dd:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetPoint("LEFT", 8, 0); label:SetText(options and options[1] and options[1].text or "")
  dd.Label = label
  dd.value = options and options[1] and options[1].value

  local btn = CreateFrame("Button", nil, dd)
  btn:SetPoint("RIGHT", -4, 0); btn:SetSize(18, 18)
  stylePanel(btn, T.tone_group)
  local t = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); t:SetPoint("CENTER"); t:SetText("▼")

  local list = CreateFrame("Frame", nil, dd, BackdropTemplateMixin and "BackdropTemplate" or nil)
  list:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -2); list:SetSize(width or 180, 10); stylePanel(list, T.tone_canvas); list:Hide()
  list.buttons = {}

  local function pick(opt)
    dd.value = opt.value; label:SetText(opt.text)
    list:Hide()
    if type(onSelect) == "function" then onSelect(opt.value, opt.text) end
  end

  if type(options) == "table" then
    local y = -4
    for _,opt in ipairs(options) do
      local b = CreateFrame("Button", nil, list)
      b:SetPoint("TOPLEFT", 4, y); b:SetPoint("RIGHT", -4, 0); b:SetHeight(20)
      local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); fs:SetPoint("LEFT", 8, 0); fs:SetText(opt.text)
      b:SetScript("OnClick", function() pick(opt) end)
      local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(true); hl:SetColorTexture(1,1,1,0.06)
      table.insert(list.buttons, b)
      y = y - 22
    end
    list:SetHeight(-y)
  end

  btn:SetScript("OnClick", function() list:SetShown(not list:IsShown()) end)
  dd.List = list
  return dd
end

function W.Verify() return W.__VERSION end
