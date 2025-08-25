-- Shade - UI Skinning Engine
-- Main addon file

local addonName, Shade = ...

-- Global addon reference
_G.Shade = Shade

-- Initialize addon state
Shade.initialized = false
Shade.modules = {}

-- Slash command handler
SLASH_SHADE1 = "/shade"
SlashCmdList["SHADE"] = function()
    Shade:ToggleMainFrame()
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            Shade:OnAddonLoaded()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not Shade.initialized then
            Shade:Initialize()
            Shade.initialized = true
        end
    end
end)

-- Print function for debugging
function Shade:Print(msg)
    print("|cff8a2be2Shade:|r " .. msg)
end