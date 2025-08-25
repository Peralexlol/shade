-- File: Shade/bootstrap.lua
-- One-file fallback to bypass parse/encoding issues in other files.
-- Encoding: UTF-8 (no BOM). ASCII-only.

-- Namespace
local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

---------------------------------------------------------------------
-- Minimal Widgets (built-in, texture-free)
---------------------------------------------------------------------
Shade.UI = Shade.UI or {}
local W = {}
Shade.UI.Widgets = W
W.__VERSION = "0.2.3"

function W.Frame(parent, name, width, height)
  local f = CreateFrame("Frame", name, parent)
  f:SetSize(width or 400, height or 300)
  return f
end

function W.Section(parent, label)
  local box = CreateFrame("Frame", nil, parent)
  box:SetSize(10, 10)
  local header = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  header:SetPoint("TOPLEFT", 10, -8)
  header:SetText(label or "Section")
  box._header = header
  return box
end

function W.Button(parent, label, width, height)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width or 100, height or 24)
  b:SetText(label or "Button")
  return b
end

function W.Input(parent, width)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetSize(width or 180, 28)
  local edit = CreateFrame("EditBox", nil, holder)
  edit:SetAutoFocus(false)
  edit:SetFontObject("GameFontHighlight")
  edit:SetPoint("LEFT", 8, 0)
  edit:SetPoint("RIGHT", -8, 0)
  edit:SetHeight(20)
  holder.EditBox = edit
  return holder
end

function W.Checkbox(parent, label)
  local cb = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
  cb:SetSize(20, 20)
  local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("LEFT", cb, "RIGHT", 8, 0)
  fs:SetText(label or "")
  cb.Label = fs
  return cb
end

function W.CloseButton(parent, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(18, 18)
  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("CENTER")
  fs:SetText("x")
  b:SetScript("OnClick", function()
    if type(onClick) == "function" then onClick() else parent:Hide() end
  end)
  return b
end

function W.Verify() return W.__VERSION end

---------------------------------------------------------------------
-- Config UI (lazy-built)
---------------------------------------------------------------------
local UI
local function EnsureUI()
  if UI and UI.__built then return true end

  UI = CreateFrame("Frame", "ShadeConfig", UIParent)
  UI:Hide(); UI:SetPoint("CENTER"); UI:SetSize(520, 380)

  local title = UI:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", 14, -12)
  title:SetText("Shade - Settings")

  local close = W.CloseButton(UI); close:SetPoint("TOPRIGHT", -10, -10)

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

---------------------------------------------------------------------
-- Slash commands (immediate)
---------------------------------------------------------------------
SLASH_SHADE1 = "/shade"; SLASH_SHADE2 = "/sui"
SlashCmdList["SHADE"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "debug" then
    print("|cff8059f2Shade|r debug:")
    print("  Widgets version:", W.Verify())
    print("  Config built:", UI and UI.__built and true or false)
  else
    Shade.ToggleConfig()
  end
end
