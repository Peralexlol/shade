-- File: Shade/ui/configui.lua (full settings – sanitized)
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- General + Modules pages, theme dropdown, sliders; trace/reset helpers.
-- Note: No raw file paths used here to avoid escape issues.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

local UI

-- Defaults + DB helpers ------------------------------------------------------
local function defaults()
  return {
    theme = "glass", alpha = 1, gloss = 0.8, border = 6,
    modules = { actionbuttons=true, tooltips=true, chat=true, auras=true, castbar=true, misc=true },
  }
end

local function getdb()
  _G.ShadeDB = _G.ShadeDB or {}
  _G.ShadeDB.profile = _G.ShadeDB.profile or defaults()
  return _G.ShadeDB.profile
end

local function bringToFront(f) f:SetFrameStrata("DIALOG"); f:SetFrameLevel(100); f:SetAlpha(1) end
local function makeMovable(f)
  f:EnableMouse(true); f:SetMovable(true); f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

-- Theme presets (can be overridden by external files)
Shade.ThemePresets = Shade.ThemePresets or {
  flatdark = { name="Flat Dark", tone_window={0.08,0.09,0.11,1}, tone_canvas={0.10,0.11,0.13,1}, tone_group={0.12,0.13,0.16,1}, accent={0.75,0.55,1,1} },
  neon     = { name="Neon",      accent={0.95,0.50,0.35,1} },
  glass    = { name="Glass",     gloss=0.8, alpha=0.9 },
  classtint= { name="Class Tint" },
}

local ORDER = {"flatdark","neon","glass","classtint"}

function Shade.applyThemeKey(key)
  local p = getdb(); p.theme = key
  local K = Shade.ThemePresets[key]
  if not K then return end
  local T = Shade.Theme
  T.tone_window = K.tone_window or T.tone_window
  T.tone_canvas = K.tone_canvas or T.tone_canvas
  T.tone_group  = K.tone_group  or T.tone_group
  T.accent      = K.accent      or T.accent
end

-- UI build -------------------------------------------------------------------
function Shade.EnsureConfig()
  if UI and UI.__built then return UI end
  if not (Shade.UI and Shade.UI.Widgets) then return nil, "widgets-missing" end
  local W = Shade.UI.Widgets

  local db = getdb()
  Shade.applyThemeKey(db.theme)

  UI = W.Window(UIParent, "ShadeConfig", 760, 520)
  if UI:GetNumPoints() == 0 then UI:SetPoint("CENTER") end
  UI:Hide(); bringToFront(UI); makeMovable(UI)

  local title = UI:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", 14, -12); title:SetText("Shade — Settings")

  local close = W.CloseButton(UI); close:SetPoint("TOPRIGHT", -10, -10)

  local tabs = CreateFrame("Frame", nil, UI); tabs:SetPoint("BOTTOMLEFT", 8, 8); tabs:SetPoint("BOTTOMRIGHT", -8, 8); tabs:SetHeight(32)
  local tabButtons = {}
  local function addTab(text, onClick)
    local b = W.Button(tabs, text, 120, 26)
    b:SetScript("OnClick", onClick)
    table.insert(tabButtons, b)
    if #tabButtons == 1 then b:SetPoint("LEFT") else b:SetPoint("LEFT", tabButtons[#tabButtons-1], "RIGHT", 6, 0) end
    return b
  end

  -- Pages
  local pageGeneral = CreateFrame("Frame", nil, UI); pageGeneral:SetPoint("TOPLEFT", 12, -40); pageGeneral:SetPoint("BOTTOMRIGHT", -12, 46)
  local pageProfiles = CreateFrame("Frame", nil, UI); pageProfiles:SetAllPoints(pageGeneral); pageProfiles:Hide()

  local function showPage(which)
    pageGeneral:SetShown(which=="general"); pageProfiles:SetShown(which=="profiles")
  end

  addTab("General", function() showPage("general") end)
  addTab("Profiles", function() showPage("profiles") end)
  showPage("general")

  -- General page ----------------------------------------------------
  local general = W.Section(pageGeneral, "General")
  general:SetPoint("TOPLEFT"); general:SetPoint("RIGHT"); general:SetHeight(220)

  -- Theme row
  local themeLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  themeLabel:SetPoint("TOPLEFT", 12, -36); themeLabel:SetText("Theme")

  local opts = {}
  for _,k in ipairs(ORDER) do table.insert(opts, {value=k, text=(Shade.ThemePresets[k] and Shade.ThemePresets[k].name or k)}) end
  local dd = W.Dropdown(general, 200, opts, function(val)
    Shade.applyThemeKey(val)
  end)
  dd:SetPoint("TOPLEFT", themeLabel, "BOTTOMLEFT", 0, -6)
  for _,o in ipairs(opts) do if o.value == db.theme then dd.Label:SetText(o.text); dd.value = o.value end end

  local alphaLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  alphaLabel:SetPoint("LEFT", dd, "RIGHT", 40, 0); alphaLabel:SetText("Alpha")
  local alpha = W.Slider(general, 0.2, 1.0, 0.05); alpha:SetPoint("LEFT", alphaLabel, "RIGHT", 8, 0); alpha:SetWidth(160); alpha:SetValue(db.alpha or 1)

  local glossLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  glossLabel:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -20); glossLabel:SetText("Gloss")
  local gloss = W.Slider(general, 0, 1.0, 0.05); gloss:SetPoint("LEFT", glossLabel, "RIGHT", 8, 0); gloss:SetWidth(160); gloss:SetValue(db.gloss or 0.8)

  local borderLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  borderLabel:SetPoint("LEFT", gloss, "RIGHT", 40, 0); borderLabel:SetText("Border")
  local border = W.Slider(general, 0, 12, 1); border:SetPoint("LEFT", borderLabel, "RIGHT", 8, 0); border:SetWidth(160); border:SetValue(db.border or 6)

  W.Separator(general, -160)

  -- Modules ---------------------------------------------------------
  local modulesBox = W.Section(pageGeneral, "Modules")
  modulesBox:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -12); modulesBox:SetPoint("RIGHT"); modulesBox:SetPoint("BOTTOM")

  local cols = {
    {"actionbuttons","Actionbuttons"},
    {"tooltips","Tooltips"},
    {"chat","Chat"},
    {"auras","Auras"},
    {"castbar","Castbar"},
    {"misc","Misc"},
  }

  local checks = {}
  local x, y = 12, -36
  for i,def in ipairs(cols) do
    local key, label = def[1], def[2]
    local cb = W.Check(modulesBox, label)
    cb:SetPoint("TOPLEFT", x, y)
    cb:SetChecked(db.modules[key] ~= false)
    checks[key] = cb
    if i == 3 then x = 220; y = -36 else y = y - 28 end
  end

  local apply = W.Button(pageGeneral, "Apply", 120, 28)
  apply:SetPoint("BOTTOMRIGHT", pageGeneral, "BOTTOMRIGHT", -12, 12)
  apply:SetScript("OnClick", function()
    local p = getdb()
    p.theme = dd.value or p.theme
    p.alpha = alpha:GetValue() or p.alpha
    p.gloss = gloss:GetValue() or p.gloss
    p.border= border:GetValue() or p.border
    for key, cb in pairs(checks) do p.modules[key] = cb:GetChecked() and true or false end

    Shade.applyThemeKey(p.theme)

    -- Enable/Disable modules live
    if Shade.modules then
      for key, m in pairs(Shade.modules) do
        local want = p.modules[key]
        if want == false and m.enabled ~= false then
          m.enabled = false; if type(m.OnDisable) == "function" then pcall(m.OnDisable, m) end
        elseif want ~= false and m.enabled == false then
          m.enabled = true; if type(m.OnEnable) == "function" then pcall(m.OnEnable, m) end
        end
      end
    end

    print("|cff8059f2Shade|r: Settings applied.")
  end)

  -- Profiles page (placeholder) ------------------------------------
  local pf = W.Section(pageProfiles, "Profiles")
  pf:SetPoint("TOPLEFT"); pf:SetPoint("RIGHT"); pf:SetPoint("BOTTOM")
  local nameField = W.Input(pf, 240); nameField:SetPoint("TOPLEFT", 12, -36); nameField.EditBox:SetText("Default")
  local save = W.Button(pf, "Save", 100, 26); save:SetPoint("LEFT", nameField, "RIGHT", 8, 0)
  save:SetScript("OnClick", function() print("|cff8059f2Shade|r: Saved profile '"..(nameField.EditBox:GetText() or "").."' (not persisted yet).") end)

  UI.__built = true
  return UI
end

function Shade.ToggleConfig(cmd)
  local f, reason = Shade.EnsureConfig()
  if not f then
    if reason == "widgets-missing" then print("|cff8059f2Shade|r: Widgets missing (ui/widgets.lua)") else print("|cff8059f2Shade|r: Could not build UI ("..tostring(reason)..").") end
    return
  end
  f:SetFrameStrata("DIALOG"); f:SetFrameLevel(100); f:SetAlpha(1)
  if cmd == "show" or cmd == "ui" then f:Show(); return end
  if cmd == "hide" then f:Hide(); return end
  if f:IsShown() then f:Hide() else f:Show() end
end

function Shade.ConfigTrace()
  local f = UI
  print("|cff8059f2Shade|r UI trace:")
  print("  exists:", f and true or false)
  if not f then return end
  print("  shown:", f:IsShown())
  print("  alpha:", string.format("%.2f", f:GetAlpha() or 1))
  print("  strata:", f:GetFrameStrata()); print("  level:", f:GetFrameLevel())
  local w,h = f:GetSize(); print("  size:", math.floor(w or 0), "x", math.floor(h or 0))
  print("  numPoints:", f:GetNumPoints()); local p,_,_,x,y = f:GetPoint(1); print("  point:", p or "nil", x or 0, y or 0)
end

function Shade.ConfigReset()
  local f, reason = Shade.EnsureConfig()
  if not f then print("|cff8059f2Shade|r: Cannot reset ("..tostring(reason)..")."); return end
  f:ClearAllPoints(); f:SetPoint("CENTER"); f:SetAlpha(1); f:SetScale(1); f:Show()
  print("|cff8059f2Shade|r: UI reset to center and shown.")
end
-- File: Shade/ui/configui.lua (full settings – sanitized)
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- General + Modules pages, theme dropdown, sliders; trace/reset helpers.
-- Note: No raw file paths used here to avoid escape issues.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end

local UI

-- Defaults + DB helpers ------------------------------------------------------
local function defaults()
  return {
    theme = "glass", alpha = 1, gloss = 0.8, border = 6,
    modules = { actionbuttons=true, tooltips=true, chat=true, auras=true, castbar=true, misc=true },
  }
end

local function getdb()
  _G.ShadeDB = _G.ShadeDB or {}
  _G.ShadeDB.profile = _G.ShadeDB.profile or defaults()
  return _G.ShadeDB.profile
end

local function bringToFront(f) f:SetFrameStrata("DIALOG"); f:SetFrameLevel(100); f:SetAlpha(1) end
local function makeMovable(f)
  f:EnableMouse(true); f:SetMovable(true); f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

-- Theme presets (can be overridden by external files)
Shade.ThemePresets = Shade.ThemePresets or {
  flatdark = { name="Flat Dark", tone_window={0.08,0.09,0.11,1}, tone_canvas={0.10,0.11,0.13,1}, tone_group={0.12,0.13,0.16,1}, accent={0.75,0.55,1,1} },
  neon     = { name="Neon",      accent={0.95,0.50,0.35,1} },
  glass    = { name="Glass",     gloss=0.8, alpha=0.9 },
  classtint= { name="Class Tint" },
}

local ORDER = {"flatdark","neon","glass","classtint"}

function Shade.applyThemeKey(key)
  local p = getdb(); p.theme = key
  local K = Shade.ThemePresets[key]
  if not K then return end
  local T = Shade.Theme
  T.tone_window = K.tone_window or T.tone_window
  T.tone_canvas = K.tone_canvas or T.tone_canvas
  T.tone_group  = K.tone_group  or T.tone_group
  T.accent      = K.accent      or T.accent
end

-- UI build -------------------------------------------------------------------
function Shade.EnsureConfig()
  if UI and UI.__built then return UI end
  if not (Shade.UI and Shade.UI.Widgets) then return nil, "widgets-missing" end
  local W = Shade.UI.Widgets

  local db = getdb()
  Shade.applyThemeKey(db.theme)

  UI = W.Window(UIParent, "ShadeConfig", 760, 520)
  if UI:GetNumPoints() == 0 then UI:SetPoint("CENTER") end
  UI:Hide(); bringToFront(UI); makeMovable(UI)

  local title = UI:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", 14, -12); title:SetText("Shade — Settings")

  local close = W.CloseButton(UI); close:SetPoint("TOPRIGHT", -10, -10)

  local tabs = CreateFrame("Frame", nil, UI); tabs:SetPoint("BOTTOMLEFT", 8, 8); tabs:SetPoint("BOTTOMRIGHT", -8, 8); tabs:SetHeight(32)
  local tabButtons = {}
  local function addTab(text, onClick)
    local b = W.Button(tabs, text, 120, 26)
    b:SetScript("OnClick", onClick)
    table.insert(tabButtons, b)
    if #tabButtons == 1 then b:SetPoint("LEFT") else b:SetPoint("LEFT", tabButtons[#tabButtons-1], "RIGHT", 6, 0) end
    return b
  end

  -- Pages
  local pageGeneral = CreateFrame("Frame", nil, UI); pageGeneral:SetPoint("TOPLEFT", 12, -40); pageGeneral:SetPoint("BOTTOMRIGHT", -12, 46)
  local pageProfiles = CreateFrame("Frame", nil, UI); pageProfiles:SetAllPoints(pageGeneral); pageProfiles:Hide()

  local function showPage(which)
    pageGeneral:SetShown(which=="general"); pageProfiles:SetShown(which=="profiles")
  end

  addTab("General", function() showPage("general") end)
  addTab("Profiles", function() showPage("profiles") end)
  showPage("general")

  -- General page ----------------------------------------------------
  local general = W.Section(pageGeneral, "General")
  general:SetPoint("TOPLEFT"); general:SetPoint("RIGHT"); general:SetHeight(220)

  -- Theme row
  local themeLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  themeLabel:SetPoint("TOPLEFT", 12, -36); themeLabel:SetText("Theme")

  local opts = {}
  for _,k in ipairs(ORDER) do table.insert(opts, {value=k, text=(Shade.ThemePresets[k] and Shade.ThemePresets[k].name or k)}) end
  local dd = W.Dropdown(general, 200, opts, function(val)
    Shade.applyThemeKey(val)
  end)
  dd:SetPoint("TOPLEFT", themeLabel, "BOTTOMLEFT", 0, -6)
  for _,o in ipairs(opts) do if o.value == db.theme then dd.Label:SetText(o.text); dd.value = o.value end end

  local alphaLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  alphaLabel:SetPoint("LEFT", dd, "RIGHT", 40, 0); alphaLabel:SetText("Alpha")
  local alpha = W.Slider(general, 0.2, 1.0, 0.05); alpha:SetPoint("LEFT", alphaLabel, "RIGHT", 8, 0); alpha:SetWidth(160); alpha:SetValue(db.alpha or 1)

  local glossLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  glossLabel:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -20); glossLabel:SetText("Gloss")
  local gloss = W.Slider(general, 0, 1.0, 0.05); gloss:SetPoint("LEFT", glossLabel, "RIGHT", 8, 0); gloss:SetWidth(160); gloss:SetValue(db.gloss or 0.8)

  local borderLabel = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  borderLabel:SetPoint("LEFT", gloss, "RIGHT", 40, 0); borderLabel:SetText("Border")
  local border = W.Slider(general, 0, 12, 1); border:SetPoint("LEFT", borderLabel, "RIGHT", 8, 0); border:SetWidth(160); border:SetValue(db.border or 6)

  W.Separator(general, -160)

  -- Modules ---------------------------------------------------------
  local modulesBox = W.Section(pageGeneral, "Modules")
  modulesBox:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -12); modulesBox:SetPoint("RIGHT"); modulesBox:SetPoint("BOTTOM")

  local cols = {
    {"actionbuttons","Actionbuttons"},
    {"tooltips","Tooltips"},
    {"chat","Chat"},
    {"auras","Auras"},
    {"castbar","Castbar"},
    {"misc","Misc"},
  }

  local checks = {}
  local x, y = 12, -36
  for i,def in ipairs(cols) do
    local key, label = def[1], def[2]
    local cb = W.Check(modulesBox, label)
    cb:SetPoint("TOPLEFT", x, y)
    cb:SetChecked(db.modules[key] ~= false)
    checks[key] = cb
    if i == 3 then x = 220; y = -36 else y = y - 28 end
  end

  local apply = W.Button(pageGeneral, "Apply", 120, 28)
  apply:SetPoint("BOTTOMRIGHT", pageGeneral, "BOTTOMRIGHT", -12, 12)
  apply:SetScript("OnClick", function()
    local p = getdb()
    p.theme = dd.value or p.theme
    p.alpha = alpha:GetValue() or p.alpha
    p.gloss = gloss:GetValue() or p.gloss
    p.border= border:GetValue() or p.border
    for key, cb in pairs(checks) do p.modules[key] = cb:GetChecked() and true or false end

    Shade.applyThemeKey(p.theme)

    -- Enable/Disable modules live
    if Shade.modules then
      for key, m in pairs(Shade.modules) do
        local want = p.modules[key]
        if want == false and m.enabled ~= false then
          m.enabled = false; if type(m.OnDisable) == "function" then pcall(m.OnDisable, m) end
        elseif want ~= false and m.enabled == false then
          m.enabled = true; if type(m.OnEnable) == "function" then pcall(m.OnEnable, m) end
        end
      end
    end

    print("|cff8059f2Shade|r: Settings applied.")
  end)

  -- Profiles page (placeholder) ------------------------------------
  local pf = W.Section(pageProfiles, "Profiles")
  pf:SetPoint("TOPLEFT"); pf:SetPoint("RIGHT"); pf:SetPoint("BOTTOM")
  local nameField = W.Input(pf, 240); nameField:SetPoint("TOPLEFT", 12, -36); nameField.EditBox:SetText("Default")
  local save = W.Button(pf, "Save", 100, 26); save:SetPoint("LEFT", nameField, "RIGHT", 8, 0)
  save:SetScript("OnClick", function() print("|cff8059f2Shade|r: Saved profile '"..(nameField.EditBox:GetText() or "").."' (not persisted yet).") end)

  UI.__built = true
  return UI
end

function Shade.ToggleConfig(cmd)
  local f, reason = Shade.EnsureConfig()
  if not f then
    if reason == "widgets-missing" then print("|cff8059f2Shade|r: Widgets missing (ui/widgets.lua)") else print("|cff8059f2Shade|r: Could not build UI ("..tostring(reason)..").") end
    return
  end
  f:SetFrameStrata("DIALOG"); f:SetFrameLevel(100); f:SetAlpha(1)
  if cmd == "show" or cmd == "ui" then f:Show(); return end
  if cmd == "hide" then f:Hide(); return end
  if f:IsShown() then f:Hide() else f:Show() end
end

function Shade.ConfigTrace()
  local f = UI
  print("|cff8059f2Shade|r UI trace:")
  print("  exists:", f and true or false)
  if not f then return end
  print("  shown:", f:IsShown())
  print("  alpha:", string.format("%.2f", f:GetAlpha() or 1))
  print("  strata:", f:GetFrameStrata()); print("  level:", f:GetFrameLevel())
  local w,h = f:GetSize(); print("  size:", math.floor(w or 0), "x", math.floor(h or 0))
  print("  numPoints:", f:GetNumPoints()); local p,_,_,x,y = f:GetPoint(1); print("  point:", p or "nil", x or 0, y or 0)
end

function Shade.ConfigReset()
  local f, reason = Shade.EnsureConfig()
  if not f then print("|cff8059f2Shade|r: Cannot reset ("..tostring(reason)..")."); return end
  f:ClearAllPoints(); f:SetPoint("CENTER"); f:SetAlpha(1); f:SetScale(1); f:Show()
  print("|cff8059f2Shade|r: UI reset to center and shown.")
end
