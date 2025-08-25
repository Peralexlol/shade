-- File: Shade/ui/configui.lua
-- Purpose: SUI-like settings window: left nav tabs, right content panel (scrollable),
--          using widgets that auto-pick your .tga media when present.

local ADDON, Shade = ...
local W = Shade.Widgets

local UI = Shade.UI or {}; Shade.UI = UI

local PAGES = {
  { key = "general",   title = "General"   },
  { key = "unitframes",title = "Unitframes"},
  { key = "nameplates",title = "Nameplates"},
  { key = "actionbar", title = "Actionbar" },
  { key = "castbars",  title = "Castbars"  },
  { key = "tooltip",   title = "Tooltip"   },
  { key = "buffs",     title = "Buffs"     },
  { key = "map",       title = "Map"       },
  { key = "chat",      title = "Chat"      },
  { key = "misc",      title = "Misc"      },
  { key = "profiles",  title = "Profiles"  },
}

local function makeScroll(container)
  local sf = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
  sf:SetPoint("TOPLEFT", 0, 0); sf:SetPoint("BOTTOMRIGHT", -24, 0)
  local inner = CreateFrame("Frame", nil, sf); inner:SetSize(10,10)
  sf:SetScrollChild(inner)
  local sb = sf.ScrollBar or _G[sf:GetName() and (sf:GetName().."ScrollBar") or ""]
  if sb and W.SkinScrollBar then W.SkinScrollBar(sb) end
  return sf, inner
end

local function buildGeneral(page)
  local y = -10
  local fs = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); fs:SetPoint("TOPLEFT", 12, y); fs:SetText("General"); y = y - 26

  local themeLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  themeLabel:SetPoint("TOPLEFT", 12, y); themeLabel:SetText("Theme"); y = y - 22
  local dd = W.Dropdown(page, 180); dd:SetPoint("TOPLEFT", 2, y); y = y - 34

  local themeKeys = {}; for key in pairs(Shade.const.themes) do table.insert(themeKeys, key) end; table.sort(themeKeys)
  UIDropDownMenu_SetWidth(dd, 150)
  UIDropDownMenu_Initialize(dd, function(self, level)
    level = level or 1
    if level == 1 then
      for _, key in ipairs(themeKeys) do
        local info = UIDropDownMenu_CreateInfo()
        info.text   = Shade.const.themes[key].name or key
        info.checked = (ShadeDB.theme == key)
        info.func    = function() Shade:ApplyTheme(key); UIDropDownMenu_SetSelectedName(dd, info.text) end
        UIDropDownMenu_AddButton(info, level)
      end
    end
  end)
  UIDropDownMenu_SetSelectedName(dd, (Shade.const.themes[ShadeDB.theme] or {}).name or ShadeDB.theme)

  local sep = W.Separator(page); sep:SetPoint("TOPLEFT", 10, y); sep:SetPoint("TOPRIGHT", -10, y); y = y - 16

  local alphaLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal"); alphaLabel:SetPoint("TOPLEFT", 12, y); alphaLabel:SetText("Alpha")
  local alpha = W.Slider(page, 0.5, 1, 0.01); alpha:SetPoint("LEFT", alphaLabel, "RIGHT", 8, 0); alpha:SetPoint("RIGHT", page, "RIGHT", -14, 0); alpha:SetValue(1); y = y - 36
  alpha:HookScript("OnValueChanged", function(_, v) UI.Root:SetAlpha(v) end)

  local sep2 = W.Separator(page); sep2:SetPoint("TOPLEFT", 10, y); sep2:SetPoint("TOPRIGHT", -10, y); y = y - 16

  local grid = {
    { key = "actionbuttons", label = "Actionbuttons" },
    { key = "tooltips",      label = "Tooltips"      },
    { key = "chat",          label = "Chat"          },
    { key = "auras",         label = "Auras"         },
    { key = "castbar",       label = "Castbar"       },
    { key = "misc",          label = "Misc"          },
  }
  local x, col = 12, 0
  for _, item in ipairs(grid) do
    local cb = W.Check(page, item.label, true); cb:SetPoint("TOPLEFT", x + (col*260), y)
    col = col + 1; if col == 2 then col = 0; y = y - 28 end
  end
  page:SetHeight(-y + 20)
end

function UI:Build()
  if self.Root then return self.Root end
  local win = W.Window("ShadeConfig", 820, 520); self.Root = win; win.Title:SetText("Shade – Settings")

  win.__themeChildren = {}
  local function track(child) table.insert(win.__themeChildren, child); return child end

  -- Left nav ---------------------------------------------------------------
  local left = track(W.Section(win)); left:SetPoint("TOPLEFT", 10, -28); left:SetPoint("BOTTOMLEFT", 10, 12); left:SetWidth(190)
  local leftInner = CreateFrame("Frame", nil, left); leftInner:SetPoint("TOPLEFT", 6, -6); leftInner:SetPoint("BOTTOMRIGHT", -6, 6)

  local navScroll, nav = makeScroll(leftInner)

  -- Right content ----------------------------------------------------------
  local right = track(W.Section(win)); right:SetPoint("TOPLEFT", left, "TOPRIGHT", 10, 0); right:SetPoint("BOTTOMRIGHT", -10, 12)
  local rightInner = CreateFrame("Frame", nil, right); rightInner:SetPoint("TOPLEFT", 6, -6); rightInner:SetPoint("BOTTOMRIGHT", -6, 6)
  local pageScroll, page = makeScroll(rightInner)

  -- Nav buttons + pages ----------------------------------------------------
  local buttons, pages = {}, {}
  local y = -4
  for i, info in ipairs(PAGES) do
    local btn = W.Button(nav, info.title, 150, 24)
    btn:SetPoint("TOPLEFT", 6, y); y = y - 28
    buttons[info.key] = btn
    btn:SetScript("OnClick", function()
      for k, b in pairs(buttons) do b.__active = false end
      btn.__active = true
      for k, f in pairs(pages) do f:Hide() end
      if not pages[info.key] then
        local p = CreateFrame("Frame", nil, page); p:SetPoint("TOPLEFT"); p:SetPoint("TOPRIGHT"); pages[info.key] = p
        if info.key == "general" then buildGeneral(p) else
          local fs = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); fs:SetPoint("TOPLEFT", 12, -12); fs:SetText(info.title)
          local small = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); small:SetPoint("TOPLEFT", 12, -44); small:SetText("(Placeholder page)")
          p:SetHeight(120)
        end
      end
      pages[info.key]:Show(); pageScroll:UpdateScrollChildRect()
    end)
  end

  -- Select first page
  buttons.general:Click()

  -- Save button ------------------------------------------------------------
  local save = track(W.Button(win, "Save", 120, 24)); save:SetPoint("BOTTOMLEFT", 12, 12)
  save:SetScript("OnClick", function() print("Shade:", "settings saved (stub)") end)

  -- Apply button -----------------------------------------------------------
  local apply = track(W.Button(win, "Apply", 120, 24)); apply:SetPoint("BOTTOMRIGHT", -12, 12)
  apply:SetScript("OnClick", function() print("Shade:", "applied settings (stub)") end)

  return win
end

function UI:Show() (self:Build()):Show() end
function UI:Hide() if self.Root then self.Root:Hide() end end

-- No auto-open; use /shade ui
