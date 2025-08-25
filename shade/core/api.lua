-- File: shade/core/api.lua (drop-in fix)

local Shade = _G.Shade
local Clamp01 = _G.Clamp01 or function(v) if v < 0 then return 0 elseif v > 1 then return 1 else return v end end

-- Minimal public API
-- Authors call:
--   local group = Shade:RegisterGroup("MyAddon", "MyButtons")
--   group:AddButton(button)

local function apply_button_skin(btn)
  if not btn then return end
  local s = Shade:GetActionbarSettings()
  local skin = Shade.Skins[Shade:GetProfile().theme or 'Shade UI']
  if not skin then return end

  -- Icon crop
  local icon = btn.icon or btn.Icon or (btn.GetName and _G[btn:GetName() .. "Icon"]) or btn.IconTexture
  if icon and icon.SetTexCoord then icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end

  -- Base overlay (dark bg)
  local base = Shade:EnsureOverlay(btn, "__shadeBase")
  if base and base.tex then base.tex:SetVertexColor(skin.bg[1], skin.bg[2], skin.bg[3], Clamp01(tonumber(s.alpha) or 1)) end

  -- Border thickness & color
  local border = Shade:EnsureBorder(btn)
  if border and border.SetBackdrop then
    border:SetBackdrop({ edgeFile = "Interface/Buttons/WHITE8x8", edgeSize = math.max(1, tonumber(s.borderThickness) or 1) })
    border:SetBackdropBorderColor(skin.border[1], skin.border[2], skin.border[3], 0.9)
  end

  -- Gloss overlay
  local gloss = Shade:EnsureOverlay(btn, "__shadeGloss")
  if gloss and gloss.tex then gloss.tex:SetVertexColor(1,1,1, Clamp01(tonumber(s.gloss) or 0)) end

  -- States
  if btn.SetHighlightTexture then
    btn:SetHighlightTexture("Interface/Buttons/WHITE8x8")
    local ht = btn:GetHighlightTexture(); if ht then ht:SetVertexColor(skin.accent[1], skin.accent[2], skin.accent[3], 0.15) end
  end
  if btn.SetCheckedTexture then
    btn:SetCheckedTexture("Interface/Buttons/WHITE8x8")
    local ct = btn:GetCheckedTexture(); if ct then ct:SetVertexColor(skin.accent[1], skin.accent[2], skin.accent[3], 0.25) end
  end

  btn.__shade_skinned = true -- informational only; we always re-apply settings
end

local Group = {}
Group.__index = Group

function Group:AddButton(btn)
  if not btn then return end
  self.buttons[btn] = true
  Shade:DeferSafe(function() apply_button_skin(btn) end)
end

function Group:reskin()
  for btn in pairs(self.buttons) do apply_button_skin(btn) end
end

function Shade:RegisterGroup(addonName, groupID, opts)
  local id = (addonName or "_") .. ":" .. (groupID or "_")
  if self.Groups[id] then return self.Groups[id] end
  local g = setmetatable({ id = id, buttons = {}, opts = opts or {} }, Group)
  self.Groups[id] = g
  return g
end

-- Built-in Blizzard action bar group id
function Shade:GetBlizzardActionbarGroup()
  if not self.Groups["blizzard/actionbars"] then
    self.Groups["blizzard/actionbars"] = setmetatable({ id = "blizzard/actionbars", buttons = {} }, Group)
  end
  return self.Groups["blizzard/actionbars"]
end
