--[=[
File: modules/BlizzSkin.lua (v0.2.3)
Fix: DF scrollbars sometimes don't expose :GetThumbTexture().
We now skin safely, handling both classic and ScrollController styles.
Also auto-enables + skins dropdown popups/tooltips/windows.
]=]

local ADDON = ...
local Shade = _G.Shade
local PRINTED

local TONE_WINDOW = {0.07, 0.075, 0.085, 0.98}
local TONE_GROUP  = {0.11, 0.12, 0.14, 0.96}
local YCHECK      = {1.00, 0.82, 0.00, 1.00}

local function once()
  if PRINTED then return end
  PRINTED = true
  DEFAULT_CHAT_FRAME:AddMessage('|cffb18cffShade|r BlizzSkin v0.2.3 active')
end

local function SkinPanel(frame, color)
  if not frame or frame.__shade_skinned then return end
  frame.__shade_skinned = true
  if frame.NineSlice and frame.NineSlice.SetAlpha then frame.NineSlice:SetAlpha(0) end
  local bg = frame:CreateTexture(nil, 'BACKGROUND'); bg:SetAllPoints(); bg:SetColorTexture(unpack(color or TONE_GROUP)); frame.__shade_bg = bg
  local ib = frame:CreateTexture(nil, 'BORDER'); ib:SetPoint('TOPLEFT',1,-1); ib:SetPoint('BOTTOMRIGHT',-1,1); ib:SetColorTexture(1,1,1,0.08)
  local ob = frame:CreateTexture(nil, 'BORDER'); ob:SetAllPoints(); ob:SetColorTexture(0,0,0,0.90)
end

local function HideTextures(owner)
  if not owner then return end
  local r = { owner:GetRegions() }
  for i=1,#r do if r[i].GetObjectType and r[i]:GetObjectType()=="Texture" then r[i]:SetAlpha(0) end end
end

local function SkinScrollBar(sb)
  if not sb or sb.__shade_sb then return end
  sb.__shade_sb = true

  -- Hide any default art on the scrollbar and its track (if any)
  HideTextures(sb)
  if sb.Track then HideTextures(sb.Track) end

  -- Flat dark track
  local track = sb:CreateTexture(nil, 'BACKGROUND')
  track:SetAllPoints(); track:SetColorTexture(0,0,0,0.25)

  -- Try classic thumb first
  local th = (sb.GetThumbTexture and sb:GetThumbTexture()) or sb.ThumbTexture
  if th and th.SetColorTexture then
    th:SetTexture('Interface/Buttons/WHITE8x8')
    th:SetColorTexture(1,1,1,0.9)
    th:SetWidth(8)
    sb:SetThumbTexture(th)
    return
  end

  -- DF ScrollController style (thumb lives under sb.Track.Thumb or similar). We only tint if it exists.
  local parent = sb.Track or sb
  local guess = (parent.Thumb and parent.Thumb.GetObjectType and parent.Thumb) or parent.ThumbTexture
  if guess and guess.SetColorTexture then
    guess:SetTexture('Interface/Buttons/WHITE8x8')
    guess:SetColorTexture(1,1,1,0.9)
    if guess.SetWidth then guess:SetWidth(8) end
  end

  -- If no known thumb object, skip (track alone is fine). Avoid creating our own so we don't fight controller logic.
end

local function SkinDropdownList()
  local maxL = _G.UIDROPDOWNMENU_MAXLEVELS or 3
  local maxB = _G.UIDROPDOWNMENU_MAXBUTTONS or 64
  for level=1, maxL do
    local back = _G['DropDownList'..level..'Backdrop']
    local menu = _G['DropDownList'..level..'MenuBackdrop']
    if back then SkinPanel(back, TONE_GROUP) end
    if menu then SkinPanel(menu, TONE_GROUP) end
    for i=1, maxB do
      local btn = _G['DropDownList'..level..'Button'..i]
      if btn and not btn.__shade_dd then
        btn.__shade_dd = true
        local fs = _G['DropDownList'..level..'Button'..i..'NormalText'] or btn:GetFontString()
        if fs then fs:SetTextColor(1,1,1,1) end
        local hl = _G['DropDownList'..level..'Button'..i..'Highlight']
        if hl and hl.SetColorTexture then hl:SetColorTexture(1,1,1,0.06); hl:SetBlendMode('ADD') end
        local check = _G['DropDownList'..level..'Button'..i..'Check']
        local unchk = _G['DropDownList'..level..'Button'..i..'UnCheck']
        if unchk then unchk:SetTexture('Interface/Buttons/WHITE8x8'); unchk:SetAlpha(0) end
        if check then
          check:SetTexture('Interface/Buttons/WHITE8x8')
          check:SetVertexColor(YCHECK[1],YCHECK[2],YCHECK[3],YCHECK[4])
          check:ClearAllPoints(); check:SetPoint('LEFT', 6, 0)
          check:SetSize(6,6)
        end
      end
    end
  end
end

local function SkinTooltip(tt)
  if not tt or tt.__shade_tt then return end
  tt.__shade_tt = true
  if tt.NineSlice and tt.NineSlice.SetAlpha then tt.NineSlice:SetAlpha(0) end
  local bg = tt:CreateTexture(nil, 'BACKGROUND')
  bg:SetPoint('TOPLEFT', 1, -1)
  bg:SetPoint('BOTTOMRIGHT', -1, 1)
  bg:SetColorTexture(0.10,0.11,0.13,0.98)
  tt.__shade_bg = bg
  local ib = tt:CreateTexture(nil, 'BORDER')
  ib:SetPoint('TOPLEFT', 1, -1)
  ib:SetPoint('BOTTOMRIGHT', -1, 1)
  ib:SetColorTexture(1,1,1,0.05)
end

local function SkinIfExists(name, tone)
  local f = _G[name]
  if f then SkinPanel(f, tone or TONE_WINDOW) end
end

local function OnAddonLoaded(addon)
  once()
  SkinIfExists('GameMenuFrame', TONE_WINDOW)
  SkinIfExists('SettingsPanel', TONE_WINDOW)
  SkinIfExists('InterfaceOptionsFrame', TONE_WINDOW)
  for i=1,4 do SkinIfExists('StaticPopup'..i, TONE_GROUP) end
  SkinIfExists('AddonList', TONE_WINDOW)
  if _G.AddonList and _G.AddonList.ScrollBar then SkinScrollBar(_G.AddonList.ScrollBar) end
  SkinTooltip(_G.GameTooltip); SkinTooltip(_G.ItemRefTooltip); for i=1,3 do SkinTooltip(_G['ShoppingTooltip'..i]) end
  SkinDropdownList()
end

-- Auto-enable
local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_LOGIN')
f:RegisterEvent('ADDON_LOADED')

f:SetScript('OnEvent', function(_, evt, arg1)
  if evt == 'PLAYER_LOGIN' then OnAddonLoaded('Blizzard') end
  if evt == 'ADDON_LOADED' then OnAddonLoaded(arg1) end
end)

-- Keep menus skinned whenever they are (re)created
if type(_G.ToggleDropDownMenu) == 'function' then hooksecurefunc('ToggleDropDownMenu', SkinDropdownList) end
if type(_G.UIDropDownMenu_CreateFrames) == 'function' then hooksecurefunc('UIDropDownMenu_CreateFrames', SkinDropdownList) end
if type(_G.UIDropDownMenu_InitializeHelper) == 'function' then hooksecurefunc('UIDropDownMenu_InitializeHelper', SkinDropdownList) end
