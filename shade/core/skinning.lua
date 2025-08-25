-- Skinning engine for Shade addon
local addonName, Shade = ...

-- Skin a frame with Shade theme
function Shade:SkinFrame(frame, config)
    if not frame then return end
    
    config = config or {}
    local alpha = config.alpha or 0.8
    local borderThickness = config.borderThickness or 2
    local gloss = config.gloss or 0.3
    
    -- Create backdrop
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = borderThickness,
        insets = { left = borderThickness, right = borderThickness, top = borderThickness, bottom = borderThickness }
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, alpha)
    frame:SetBackdropBorderColor(0.541, 0.169, 0.886, 1)  -- Direct purple accent color
end

-- Apply action bar skinning
function Shade:ApplyActionBarSkins()
    if not self.db or not self.db.actionbars.enabled then
        return
    end
    
    local config = self.db.actionbars
    
    -- Get all action bar buttons
    local buttons = {}
    
    -- Main action bar
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            table.insert(buttons, button)
        end
    end
    
    -- MultiBarBottomLeft
    for i = 1, 12 do
        local button = _G["MultiBarBottomLeftButton" .. i]
        if button then
            table.insert(buttons, button)
        end
    end
    
    -- MultiBarBottomRight
    for i = 1, 12 do
        local button = _G["MultiBarBottomRightButton" .. i]
        if button then
            table.insert(buttons, button)
        end
    end
    
    -- MultiBarRight
    for i = 1, 12 do
        local button = _G["MultiBarRightButton" .. i]
        if button then
            table.insert(buttons, button)
        end
    end
    
    -- MultiBarLeft
    for i = 1, 12 do
        local button = _G["MultiBarLeftButton" .. i]
        if button then
            table.insert(buttons, button)
        end
    end
    
    -- Skin each button
    for _, button in ipairs(buttons) do
        self:SkinActionButton(button, config)
    end
end

-- Skin individual action button
function Shade:SkinActionButton(button, config)
    if not button then return end
    
    -- Hide default textures
    if button.SetNormalTexture then
        button:SetNormalTexture("")
    end
    
    -- Create or update shade skin
    if not button.shadeSkin then
        button.shadeSkin = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.shadeSkin:SetAllPoints(button)
        button.shadeSkin:SetFrameLevel(button:GetFrameLevel() - 1)
    end
    
    -- Apply backdrop
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = config.borderThickness,
        insets = { 
            left = config.borderThickness, 
            right = config.borderThickness, 
            top = config.borderThickness, 
            bottom = config.borderThickness 
        }
    }
    
    button.shadeSkin:SetBackdrop(backdrop)
    button.shadeSkin:SetBackdropColor(0.05, 0.05, 0.05, config.alpha)
    button.shadeSkin:SetBackdropBorderColor(0.541, 0.169, 0.886, config.gloss)  -- Direct purple accent color
    
    -- Show the skin
    button.shadeSkin:Show()
end

-- Remove skinning
function Shade:RemoveActionBarSkins()
    local buttons = {}
    
    -- Collect all buttons (same as above)
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then table.insert(buttons, button) end
    end
    
    for i = 1, 12 do
        local button = _G["MultiBarBottomLeftButton" .. i]
        if button then table.insert(buttons, button) end
    end
    
    for i = 1, 12 do
        local button = _G["MultiBarBottomRightButton" .. i]
        if button then table.insert(buttons, button) end
    end
    
    for i = 1, 12 do
        local button = _G["MultiBarRightButton" .. i]
        if button then table.insert(buttons, button) end
    end
    
    for i = 1, 12 do
        local button = _G["MultiBarLeftButton" .. i]
        if button then table.insert(buttons, button) end
    end
    
    -- Remove skins
    for _, button in ipairs(buttons) do
        if button.shadeSkin then
            button.shadeSkin:Hide()
        end
    end
end