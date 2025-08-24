--[=[
File: ui/ConfigUI.lua (v0.2.0)
Change: swap the single-line EditBox in Profiles -> Manage to use W.Input so it
matches the SUI-styled widgets. No other logic changed.
]=]

local ADDON = ...
local Shade = _G.Shade
local W = Shade.UI.Widgets

local pages = {}
local frame

local function ApplyFromControls()
  local P = Shade:GetProfileTable()
  local g = pages.General
  if g then
    local val = UIDropDownMenu_GetSelectedValue(g.skin)
    if val then P.skin = val end
    P.border = math.floor(g.border:GetValue() or P.border)
    P.alpha  = tonumber(('%0.2f'):format(g.alpha:GetValue() or P.alpha))
    P.gloss  = tonumber(('%0.2f'):format(g.gloss:GetValue() or P.gloss))
    for key,cb in pairs(g.modules) do P.modules[key] = cb:GetChecked() and true or false end
  end
  Shade:EnableConfiguredModules(); Shade:ReapplyAll()
end

local function BuildGeneral(parent)
  local p = CreateFrame('Frame', nil, parent)
  p:SetAllPoints(parent)
  pages.General = p

  local header = p:CreateFontString(nil, 'OVERLAY')
  header:SetPoint('TOPLEFT', 20, -18)
  header:SetFont(Shade.media.font or STANDARD_TEXT_FONT, 18, '')
  header:SetTextColor(1,1,1,1)
  header:SetText('General')

  local g1 = W.Section(p, 'Theme'); g1:SetPoint('TOPLEFT', 16, -52); g1:SetSize(640, 150)
  local g2 = W.Section(p, 'Modules'); g2:SetPoint('TOPLEFT', g1, 'BOTTOMLEFT', 0, -12); g2:SetSize(640, 170)

  -- Theme controls
  local skinDD = W.Dropdown(g1, 180); skinDD:SetPoint('TOPLEFT', 10, -36)
  UIDropDownMenu_SetWidth(skinDD, 160)
  UIDropDownMenu_Initialize(skinDD, function(self)
    local function add(key, text)
      local info = UIDropDownMenu_CreateInfo()
      info.text = text; info.value = key; info.func = function() UIDropDownMenu_SetSelectedValue(skinDD, key) end
      UIDropDownMenu_AddButton(info)
    end
    add('flat_dark','Flat Dark'); add('neon','Neon'); add('glass','Glass'); add('class_tint','Class Tint')
  end)
  local lbl1 = g1:CreateFontString(nil,'OVERLAY'); lbl1:SetPoint('LEFT', skinDD, 'RIGHT', -10, 3)
  lbl1:SetFont(Shade.media.font or STANDARD_TEXT_FONT, 14, '')
  lbl1:SetTextColor(1,1,1,1)
  lbl1:SetText('Skin')

  local border = W.Slider(g1, 'Border', 0, 6, 1, 260); border:SetPoint('TOPLEFT', 10, -72)
  local alpha  = W.Slider(g1, 'Alpha', 0.2, 1.0, 0.05, 260); alpha:SetPoint('LEFT', border, 'RIGHT', 40, 0)
  local gloss  = W.Slider(g1, 'Gloss', 0.0, 0.8, 0.05, 260); gloss:SetPoint('TOPLEFT', border, 'BOTTOMLEFT', 0, -24)

  p.skin, p.border, p.alpha, p.gloss = skinDD, border, alpha, gloss

  -- Modules
  p.modules = {}
  local keys = {'actionbuttons','auras','tooltips','castbar','chat','misc'}
  local x,y = 10,-36
  for _,k in ipairs(keys) do
    local name = k:gsub('^%l', string.upper)
    local cb = W.Check(g2, name)
    cb:SetPoint('TOPLEFT', x,y)
    p.modules[k] = cb
    if x>320 then x=10; y=y-28 else x=x+330 end
  end

  -- Apply button
  local apply = W.Button(p, 'Apply', 110, 28); apply:SetPoint('BOTTOMRIGHT', -18, 18)
  apply:SetScript('OnClick', ApplyFromControls)

  p:Hide(); return p
end

local function BuildProfiles(parent)
  local p = CreateFrame('Frame', nil, parent)
  p:SetAllPoints(parent)
  pages.Profiles = p

  local header = p:CreateFontString(nil, 'OVERLAY')
  header:SetPoint('TOPLEFT', 20, -18)
  header:SetFont(Shade.media.font or STANDARD_TEXT_FONT, 18, '')
  header:SetTextColor(1,1,1,1)
  header:SetText('Profiles')

  local g = W.Section(p, 'Manage'); g:SetPoint('TOPLEFT', 16, -52); g:SetSize(640, 120)
  -- CHANGED: single-line input now uses W.Input for SUI styling
  local nameBox = W.Input(g, 240)
  nameBox:SetPoint('TOPLEFT', 12, -40)

  local mk = W.Button(g, 'Set Active', 120, 26); mk:SetPoint('LEFT', nameBox, 'RIGHT', 8, 0)
  mk:SetScript('OnClick', function() local txt = nameBox:GetText(); if txt and txt~='' then Shade:SetProfile(txt) end end)

  local g2 = W.Section(p, 'Share'); g2:SetPoint('TOPLEFT', g, 'BOTTOMLEFT', 0, -12); g2:SetSize(640, 220)
  local eb = W.EditBoxMultiline(g2, 600, 140); eb:SetPoint('TOPLEFT', 12, -40)
  local ex = W.Button(g2, 'Export', 100, 24); ex:SetPoint('TOPLEFT', eb, 'BOTTOMLEFT', 0, -8)
  ex:SetScript('OnClick', function() eb.edit:SetText(Shade.Profiles:Export()) eb.edit:HighlightText() end)
  local im = W.Button(g2, 'Import', 100, 24); im:SetPoint('LEFT', ex, 'RIGHT', 8, 0)
  im:SetScript('OnClick', function() local ok, why = Shade.Profiles:Import(eb.edit:GetText()); if not ok then UIErrorsFrame:AddMessage('Shade import failed: '..(why or '?'), 1, .2, .2) end end)

  p:Hide(); return p
end

local function BuildWindow()
  frame = W.Frame(UIParent, 960, 560)
  frame:SetPoint('CENTER')
  frame:SetFrameStrata('DIALOG')
  frame:SetMovable(true); frame:EnableMouse(true)

  local header = W.Header(frame, 'Shade — Settings')
  header:EnableMouse(true)
  header:RegisterForDrag('LeftButton')
  header:SetScript('OnDragStart', function() frame:StartMoving() end)
  header:SetScript('OnDragStop', function() frame:StopMovingOrSizing() end)
  local close = W.Close(frame); close:SetPoint('TOPRIGHT', -6, -6)

  local content = W.Canvas(frame)
  content:SetPoint('TOPLEFT', 10, -44)
  content:SetPoint('BOTTOMRIGHT', -10, 52)

  pages.General = BuildGeneral(content)
  pages.Profiles = BuildProfiles(content)

  local tabs = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
  tabs:SetPoint('BOTTOMLEFT', 10, 10); tabs:SetPoint('BOTTOMRIGHT', -10, 10); tabs:SetHeight(34)
  tabs:SetBackdrop({ bgFile='Interface/Buttons/WHITE8x8', edgeFile='Interface/Buttons/WHITE8x8', edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
  tabs:SetBackdropColor(.13,.14,.17,1); tabs:SetBackdropBorderColor(0,0,0,.9)

  local order = {'General','Profiles'}
  local tabButtons, last = {}, nil
  local function ShowPage(name, btn)
    for _,p in pairs(pages) do p:Hide() end
    local P = Shade:GetProfileTable()
    local g = pages.General
    if g and name=='General' then
      UIDropDownMenu_SetSelectedValue(g.skin, P.skin)
      g.border:SetValue(P.border)
      g.alpha:SetValue(P.alpha)
      g.gloss:SetValue(P.gloss)
      for k,cb in pairs(g.modules) do cb:SetChecked(P.modules[k]) end
    end
    pages[name]:Show()
    for _,b in ipairs(tabButtons) do b.topline:SetAlpha(0.25) end
    btn.topline:SetAlpha(1)
  end
  for _,name in ipairs(order) do
    local tab = W.Tab(tabs, name)
    table.insert(tabButtons, tab)
    if not last then tab:SetPoint('LEFT', 8, 0) else tab:SetPoint('LEFT', last, 'RIGHT', 8, 0) end
    tab:SetScript('OnClick', function() ShowPage(name, tab) end)
    last = tab
  end
  ShowPage('General', tabButtons[1])

  frame:Hide()
end

ShadeUI = {}
function ShadeUI.Toggle()
  if not frame then BuildWindow() end
  frame:SetShown(not frame:IsShown())
end
