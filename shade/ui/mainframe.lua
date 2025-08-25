-- Main UI frame for Shade addon
local addonName, Shade = ...

function Shade:CreateMainFrame()
    if self.MainFrame then
        return
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "ShadeMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(Shade.UI.MainFrameWidth, Shade.UI.MainFrameHeight)
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
    frame:SetBackdropColor(unpack(Shade.Colors.Background))
    frame:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Drag functionality
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Title bar
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Shade - UI Skinning Engine")
    title:SetTextColor(unpack(Shade.Colors.Text))
    
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
    closeText:SetTextColor(unpack(Shade.Colors.Text))
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    
    closeBtn:SetScript("OnEnter", function()
        closeText:SetTextColor(unpack(Shade.Colors.Accent))
    end)
    closeBtn:SetScript("OnLeave", function()
        closeText:SetTextColor(unpack(Shade.Colors.Text))
    end)
    
    -- Sidebar
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetSize(Shade.UI.SidebarWidth, Shade.UI.MainFrameHeight - 60)
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
    content:SetSize(Shade.UI.MainFrameWidth - Shade.UI.SidebarWidth - 30, Shade.UI.MainFrameHeight - 60)
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