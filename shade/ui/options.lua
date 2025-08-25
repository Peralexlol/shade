-- File: shade/ui/options.lua (drop-in fix)

local Shade = _G.Shade

-- Colors
local function GetDarkRGB()
  if _G.HexToRGB then return _G.HexToRGB("#232323") end
  return 35/255, 35/255, 35/255
end
local darkR, darkG, darkB = GetDarkRGB()
local accR, accG, accB = 0.42, 0.16, 0.59

-- Fonts
local function F(sz, flags) return (Shade.GetFont and Shade:GetFont(sz, flags)) or GameFontHighlight end

-- Widgets
local TEX = "Interface/Buttons/WHITE8x8"

local function NewFrame(name, parent, w, h)
  local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
  f:SetSize(w, h)
  if Shade and Shade.StylePanel then Shade:StylePanel(f) end
  return f
end

local function NewButton(parent, text, w, h)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(w, h)
  b:SetBackdrop({ bgFile = TEX, edgeFile = TEX, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } })
  b:SetBackdropColor(darkR, darkG, darkB, 0.9)
  b:SetBackdropBorderColor(accR, accG, accB, 0.9)
  local t = b:CreateFontString(nil, "OVERLAY")
  t:SetPoint("CENTER")
  t:SetFontObject(F(13, ""))
  t:SetTextColor(1,1,1)
  t:SetText(text)
  b.label = t
  b:SetHighlightTexture(TEX)
  local ht = b:GetHighlightTexture()
  ht:SetVertexColor(accR, accG, accB, 0.18)
  return b
end

local function NewSlider(parent, label, minV, maxV, step)
  local s = CreateFrame("Slider", nil, parent, "BackdropTemplate")
  s:SetOrientation("HORIZONTAL")
  s:SetMinMaxValues(minV, maxV)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(320)
  s:SetHeight(16)

  local bg = s:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetTexture(TEX)
  bg:SetVertexColor(0,0,0,0.4)

  local thumb = s:CreateTexture(nil, "OVERLAY")
  thumb:SetTexture(TEX)
  thumb:SetSize(10, 18)
  thumb:SetVertexColor(accR, accG, accB, 1)
  s:SetThumbTexture(thumb)

  local title = parent:CreateFontString(nil, "OVERLAY")
  title:SetFontObject(F(13, ""))
  title:SetTextColor(1,1,1)
  title:SetText(label)
  title:SetPoint("BOTTOMLEFT", s, "TOPLEFT", 0, 6)

  local val = parent:CreateFontString(nil, "OVERLAY")
  val:SetFontObject(F(12, ""))
  val:SetTextColor(1,1,1)
  val:SetPoint("BOTTOMRIGHT", s, "TOPRIGHT", 0, 6)

  s._valueText = val
  s:SetScript("OnValueChanged", function(self, v)
    if step >= 1 then
      self._valueText:SetText(string.format("%d", v))
    else
      self._valueText:SetText(string.format("%.2f", v))
    end
  end)

  return s
end

-- Custom dropdown; returns the wrapper frame for anchoring
local function NewDropdown(parent, label, items, onSelect, initial)
  local wrapper = NewFrame(nil, parent, 320, 52)

  local lab = wrapper:CreateFontString(nil, "OVERLAY")
  lab:SetFontObject(F(13, ""))
  lab:SetTextColor(1,1,1)
  lab:SetPoint("TOPLEFT", 8, -6)
  lab:SetText(label)

  local btn = NewButton(wrapper, initial or items[1], 280, 24)
  btn:SetPoint("BOTTOMLEFT", 8, 6)

  local menu = CreateFrame("Frame", nil, wrapper, "BackdropTemplate")
  if Shade and Shade.StylePanel then Shade:StylePanel(menu) end
  menu:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -4)
  menu:SetSize(280, (#items*24)+8)
  menu:Hide()

  btn:SetScript("OnClick", function()
    if menu:IsShown() then menu:Hide() else menu:Show() end
  end)

  local function addItem(idx, name)
    local it = NewButton(menu, name, 264, 20)
    it:SetPoint("TOPLEFT", 8, -4 - (idx-1)*24)
    it:SetScript("OnClick", function()
      btn.label:SetText(name)
      menu:Hide()
      if onSelect then onSelect(name) end
    end)
  end
  for i, n in ipairs(items) do addItem(i, n) end

  return wrapper
end

-- Root options window
local UI = {}
function ShadeOptions_Toggle()
  if UI.frame and UI.frame:IsShown() then UI.frame:Hide() else UI:Create():Show() end
end

function UI:Create()
  if self.frame then return self.frame end
  local f = NewFrame("ShadeOptionsFrame", UIParent, 720, 440)
  f:SetPoint("CENTER")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  -- Title
  local title = f:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOPLEFT", 16, -12)
  title:SetFontObject(F(18, ""))
  title:SetTextColor(1,1,1)
  title:SetText("Shade - UI Skinning Engine")

  -- Close
  local close = NewButton(f, "X", 28, 24)
  close:SetPoint("TOPRIGHT", -8, -8)
  close:SetScript("OnClick", function() f:Hide() end)

  -- Left nav
  local nav = NewFrame(nil, f, 180, 380)
  nav:SetPoint("TOPLEFT", 12, -44)

  local content = NewFrame(nil, f, 510, 380)
  content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 12, 0)

  local function clearContent()
    for _, child in ipairs({ content:GetChildren() }) do child:Hide() child:SetParent(nil) end
  end

  -- Pages
  local function page_actionbars()
    clearContent()
    local p = CreateFrame("Frame", nil, content, "BackdropTemplate")
    p:SetAllPoints(content)

    local settings = Shade:GetActionbarSettings()
    local currentTheme = (Shade:GetProfile() and Shade:GetProfile().theme) or "Shade UI"

    local themeDD = NewDropdown(p, "Theme", { "Shade UI" }, function(name)
      local prof = Shade:GetProfile(); prof.theme = name; Shade:ReskinAll() end, currentTheme)
    themeDD:SetPoint("TOPLEFT", 16, -16)

    -- Border Thickness
    local s1 = NewSlider(p, "Border Thickness", 0, 8, 1)
    s1:SetPoint("TOPLEFT", themeDD, "BOTTOMLEFT", 0, -24)
    s1:SetScript("OnValueChanged", function(_, v) Shade:UpdateActionbarSettings({ borderThickness = v }) end)
    s1:SetValue(settings.borderThickness or 2)

    -- Background Alpha
    local s2 = NewSlider(p, "Background Alpha", 0, 1, 0.01)
    s2:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", 0, -28)
    s2:SetScript("OnValueChanged", function(_, v) Shade:UpdateActionbarSettings({ alpha = v }) end)
    s2:SetValue(settings.alpha or 0.92)

    -- Gloss
    local s3 = NewSlider(p, "Gloss", 0, 1, 0.01)
    s3:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -28)
    s3:SetScript("OnValueChanged", function(_, v) Shade:UpdateActionbarSettings({ gloss = v }) end)
    s3:SetValue(settings.gloss or 0.12)

    local apply = NewButton(p, "Apply", 120, 28)
    apply:SetPoint("BOTTOMLEFT", 16, 16)
    apply:SetScript("OnClick", function() Shade:ReskinActionbars(); Shade:Print("Applied actionbar skin.") end)

    local save = NewButton(p, "Save", 120, 28)
    save:SetPoint("LEFT", apply, "RIGHT", 12, 0)
    save:SetScript("OnClick", function() Shade:Print("Saved.") end)

    return p
  end

  local function page_profiles()
    clearContent()
    local p = CreateFrame("Frame", nil, content, "BackdropTemplate")
    p:SetAllPoints(content)

    local exportBtn = NewButton(p, "Export", 100, 26)
    exportBtn:SetPoint("TOPLEFT", 16, -16)

    local edit = CreateFrame("EditBox", nil, p, "BackdropTemplate")
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(F(12, ""))
    edit:SetSize(470, 240)
    edit:SetPoint("TOPLEFT", exportBtn, "BOTTOMLEFT", 0, -12)
    edit:SetBackdrop({ bgFile = TEX, edgeFile = TEX, edgeSize = 1, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    edit:SetBackdropColor(darkR, darkG, darkB, 0.9)
    edit:SetBackdropBorderColor(accR, accG, accB, 0.9)
    edit:SetTextColor(1,1,1)

    exportBtn:SetScript("OnClick", function()
      edit:SetText(Shade:ExportProfile())
      edit:HighlightText()
      Shade:Print("Profile exported.")
    end)

    local importBtn = NewButton(p, "Import", 100, 26)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 12, 0)

    importBtn:SetScript("OnClick", function()
      local s = edit:GetText() or ''
      local ok, name = Shade:ImportProfileString(s)
      if ok then
        Shade:Print('Imported as profile: ' .. name)
      else
        Shade:Print('Import failed: ' .. (name or 'Unknown'))
      end
    end)

    return p
  end

  -- Left nav buttons
  local b1 = NewButton(nav, "Actionbars", nav:GetWidth()-16, 32)
  b1:SetPoint("TOPLEFT", 8, -8)
  b1:SetScript("OnClick", page_actionbars)

  local b2 = NewButton(nav, "Profiles", nav:GetWidth()-16, 32)
  b2:SetPoint("TOPLEFT", b1, "BOTTOMLEFT", 0, -8)
  b2:SetScript("OnClick", page_profiles)

  -- Default page
  page_actionbars()

  self.frame = f
  return f
end
