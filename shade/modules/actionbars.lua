-- File: shade/modules/actionbars.lua

local Shade = _G.Shade

local function collect_default_action_buttons()
  local names = {
    "ActionButton", -- main bar
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
  }
  local list = {}
  for _, prefix in ipairs(names) do
    for i = 1, 12 do
      local b = _G[prefix .. i]
      if b then table.insert(list, b) end
    end
  end
  return list
end

local function register_all()
  local group = Shade:GetBlizzardActionbarGroup()
  for _, btn in ipairs(collect_default_action_buttons()) do
    group:AddButton(btn)
  end
end

-- Reskin on actionbar updates too
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
ev:RegisterEvent("UPDATE_BINDINGS")
ev:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
ev:RegisterEvent("ACTIONBAR_SHOWGRID")
ev:RegisterEvent("ACTIONBAR_HIDEGRID")
ev:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    register_all()
  else
    Shade:ReskinActionbars()
  end
end)
