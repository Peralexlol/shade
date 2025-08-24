-- File: Shade/ui/ConfigUI.lua
-- Build config lazily. Exposes Shade.ToggleConfig; no slash here.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

local UI

local function EnsureUI()
  if UI and UI.__built then return true end
  if not (Shade.UI and Shade.UI.Widgets) then
    return false, "widgets-missing"
  end
  local W = Shade.UI.Widgets

  UI = CreateFrame("Frame", "ShadeConfig", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  UI:Hide()
  UI:SetPoint("CENTER")
  UI:SetSize(520, 380)

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
  local ok, reason = EnsureUI()
  if not ok then
    if reason == "widgets-missing" then
      print("|cff8059f2Shade|r: Widgets missing. Ensure ui/Widgets.lua loads before this file in Shade.toc.")
    else
      print("|cff8059f2Shade|r: Could not build UI ("..tostring(reason)..").")
    end
    return
  end
  if UI:IsShown() then UI:Hide() else UI:Show() end
end
