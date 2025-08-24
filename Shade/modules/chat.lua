--[=[
File: modules/Chat.lua
Minimal chat frame tidy: darker background & tab look.
]=]

local Shade = _G.Shade

local M = { name = 'chat' }

local function styleChat(cf)
  if not cf or cf.__shade_chat then return end
  cf.__shade_chat = true
  local bg = _G[cf:GetName()..'Background']
  if bg then bg:SetColorTexture(0,0,0,0.25) end
  local tab = _G[cf:GetName()..'Tab']
  if tab and tab.Text then tab.Text:SetFont(Shade.media.font, 12, 'OUTLINE') end
end

function M:Enable()
  for i=1, NUM_CHAT_WINDOWS do styleChat(_G['ChatFrame'..i]) end
end

Shade:RegisterModule(M.name, M)
