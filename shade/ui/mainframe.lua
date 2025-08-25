-- Main UI frame for Shade addon
local addonName, Shade = ...

function Shade:CreateMainFrame()
    if self.MainFrame then
        return
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "ShadeMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(600, 450)  -- Direct values instead of Shade.UI constants
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    -- Set backdrop
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 32,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.137, 0.137, 0.137, 1)  -- Direct color values
    frame:SetBackdropBorderColor(0.4, 0.1, 0.6, 1)
    
    -- Drag functionality
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Title bar
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Shade - UI Skinning Engine")
    title:SetTextColor(1, 1, 1, 1)  -- Direct white color
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Style the close button
    closeBtn:SetNormalTexture("")
    closeBtn:SetHighlightTexture("")
    closeBtn:SetPushedTexture("")
    
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER")
    closeText:SetText("×")
    closeText:SetTextColor(1, 1, 1, 1)  -- Direct white color
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    
    closeBtn:SetScript("OnEnter", function()
        closeText:SetTextColor(0.541, 0.169, 0.886, 1)  -- Direct purple color
    end)
    closeBtn:SetScript("OnLeave", function()
        closeText:SetTextColor(1, 1, 1, 1)  -- Direct white color
    end)
    
    -- Sidebar
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetSize(150, 390)  -- Direct values: 150 width, 390 height (450-60)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
    
    local sidebarBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    sidebar:SetBackdrop(sidebarBackdrop)
    sidebar:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    sidebar:SetBackdropBorderColor(0.3, 0.1, 0.5, 1)
    
    -- Content area
    local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    content:SetSize(420, 390)  -- Direct values: 420 width (600-150-30), 390 height (450-60)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    
    content:SetBackdrop(sidebarBackdrop)
    content:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
    content:SetBackdropBorderColor(0.3, 0.1, 0.5, 1)
    
    -- Store references
    frame.sidebar = sidebar
    frame.content = content
    frame.title = title
    
    self.MainFrame = frame
    
    -- Create navigation and panels
    self:CreateNavigation()
    self:CreatePanels()
end

function Shade:ToggleMainFrame()
    if not self.MainFrame then
        self:CreateMainFrame()
    end
    
    if self.MainFrame:IsShown() then
        self.MainFrame:Hide()
    else
        self.MainFrame:Show()
    end
end