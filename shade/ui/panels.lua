-- Panel system for Shade addon
local addonName, Shade = ...

Shade.Panels = {}
Shade.CurrentPanel = nil

function Shade:CreateNavigation()
    if not self.MainFrame then return end
    
    local sidebar = self.MainFrame.sidebar
    
    -- Navigation buttons
    self.NavButtons = {}
    
    -- Actionbars button
    local actionbarsBtn = self:CreateNavButton(sidebar, "Actionbars", 0)
    actionbarsBtn:SetScript("OnClick", function()
        self:ShowPanel("Actionbars")
    end)
    
    -- Profiles button
    local profilesBtn = self:CreateNavButton(sidebar, "Profiles", 1)
    profilesBtn:SetScript("OnClick", function()
        self:ShowPanel("Profiles")
    end)
    
    -- Show actionbars panel by default
    self:ShowPanel("Actionbars")
end

function Shade:ShowPanel(panelName)
    -- Create main panel if it doesn't exist
    if not self.MainPanel then
        local content = self.MainFrame.content
        self.MainPanel = CreateFrame("Frame", "ShadeMainPanel", content)
        self.MainPanel:SetAllPoints(content)
        self.MainPanel:Show()
    end
    
    -- Clear existing content by destroying all children
    local children = {self.MainPanel:GetChildren()}
    for _, child in ipairs(children) do
        child:SetParent(nil)
    end
    
    -- Reset all nav buttons
    for name, button in pairs(self.NavButtons) do
        if button then
            button:SetBackdropColor(0.2, 0.2, 0.2, 1)
            button.text:SetTextColor(1, 1, 1, 1)
        end
    end
    
    -- Create content based on panel type
    if panelName == "Actionbars" then
        self:CreateActionbarsContent(self.MainPanel)
    elseif panelName == "Profiles" then
        self:CreateProfilesContent(self.MainPanel)
    end
    
    -- Highlight current button
    if self.NavButtons[panelName] then
        self.NavButtons[panelName]:SetBackdropColor(0.3, 0.3, 0.3, 1)
        self.NavButtons[panelName].text:SetTextColor(0.541, 0.169, 0.886, 1)
    end
    
    self.CurrentPanel = panelName
end

-- Create actionbars content inside the given parent
function Shade:CreateActionbarsContent(parent)
    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20)
    title:SetText("Action Bars")
    title:SetTextColor(1, 1, 1, 1)
    
    local yOffset = -60
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    enableCheck:SetSize(16, 16)
    enableCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    
    local checkBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    enableCheck:SetBackdrop(checkBackdrop)
    enableCheck:SetBackdropColor(0.1, 0.1, 0.1, 1)
    enableCheck:SetBackdropBorderColor(0.4, 0.1, 0.6, 1)
    
    -- Check mark
    local checkMark = enableCheck:CreateTexture(nil, "OVERLAY")
    checkMark:SetTexture("Interface\\Buttons\\WHITE8X8")
    checkMark:SetSize(8, 8)
    checkMark:SetPoint("CENTER")
    checkMark:SetColorTexture(0.541, 0.169, 0.886, 1)
    checkMark:SetShown(self.db.actionbars.enabled)
    
    enableCheck:SetScript("OnClick", function()
        self.db.actionbars.enabled = not self.db.actionbars.enabled
        checkMark:SetShown(self.db.actionbars.enabled)
        
        if self.db.actionbars.enabled then
            self:ApplyActionBarSkins()
        else
            self:RemoveActionBarSkins()
        end
    end)
    
    -- Enable label
    local enableLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 10, 0)
    enableLabel:SetText("Enable Action Bar Skinning")
    enableLabel:SetTextColor(1, 1, 1, 1)
    
    yOffset = yOffset - 50
    
    -- Apply and Save buttons
    local applyBtn = self:CreateStyledButton(parent, "Apply", 80, 25)
    applyBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    applyBtn:SetScript("OnClick", function()
        self:ApplySettings()
    end)
    
    local saveBtn = self:CreateStyledButton(parent, "Save", 80, 25)
    saveBtn:SetPoint("LEFT", applyBtn, "RIGHT", 10, 0)
    saveBtn:SetScript("OnClick", function()
        self:SaveProfile()
    end)
end

-- Create profiles content inside the given parent
function Shade:CreateProfilesContent(parent)
    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20)
    title:SetText("Profiles")
    title:SetTextColor(1, 1, 1, 1)
    
    local yOffset = -60
    
    -- Export section
    local exportLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    exportLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    exportLabel:SetText("Export Profile")
    exportLabel:SetTextColor(1, 1, 1, 1)
    
    yOffset = yOffset - 30
    
    local exportBtn = self:CreateStyledButton(parent, "Generate Export Code", 150, 25)
    exportBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    exportBtn:SetScript("OnClick", function()
        self:Print("Export button clicked - feature coming soon!")
    end)
    
    -- Simple test content
    local testText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testText:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -150)
    testText:SetText("Profiles panel is working!")
    testText:SetTextColor(1, 1, 1, 1)
end

function Shade:CreateNavButton(parent, text, index)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(130, 25)  -- Direct values: 130 width (150-20), 25 height
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10 - (index * 30))  -- Direct spacing: 25+5=30
    
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    button:SetBackdrop(backdrop)
    button:SetBackdropColor(0.2, 0.2, 0.2, 1)
    button:SetBackdropBorderColor(0.4, 0.1, 0.6, 1)
    
    -- Button text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(1, 1, 1, 1)
    
    -- Hover effects
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(0.3, 0.3, 0.3, 1)
        buttonText:SetTextColor(0.541, 0.169, 0.886, 1)
    end)
    
    button:SetScript("OnLeave", function()
        if self.CurrentPanel ~= text then
            button:SetBackdropColor(0.2, 0.2, 0.2, 1)
            buttonText:SetTextColor(1, 1, 1, 1)
        end
    end)
    
    button.text = buttonText
    self.NavButtons[text] = button
    
    return button
end

function Shade:CreatePanels()
    -- Panels will be created on-demand
    self.Panels = {}
end

-- Helper function to create styled buttons
function Shade:CreateStyledButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 100, height or 25)  -- Direct default height value
    
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    button:SetBackdrop(backdrop)
    button:SetBackdropColor(0.2, 0.2, 0.2, 1)
    button:SetBackdropBorderColor(0.541, 0.169, 0.886, 1)
    
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(1, 1, 1, 1)
    
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(0.3, 0.3, 0.3, 1)
    end)
    
    button:SetScript("OnLeave", function()
        button:SetBackdropColor(0.2, 0.2, 0.2, 1)
    end)
    
    return button
end