-- Actionbars module for Shade addon
local addonName, Shade = ...

function Shade:CreateActionbarsPanel()
    if self.Panels["Actionbars"] then return end
    
    -- Safety check for db
    if not self.db or not self.db.actionbars then
        self:Print("Error: Profile data not loaded properly!")
        return
    end
    
    local content = self.MainFrame.content
    local panel = CreateFrame("Frame", nil, content)
    panel:SetAllPoints(content)
    panel:Hide()
    
    -- Panel title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -20)
    title:SetText("Action Bars")
    title:SetTextColor(unpack(Shade.Colors.Text))
    
    local yOffset = -60
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, panel, "BackdropTemplate")
    enableCheck:SetSize(16, 16)
    enableCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
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
    enableCheck:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Check mark
    local checkMark = enableCheck:CreateTexture(nil, "OVERLAY")
    checkMark:SetTexture("Interface\\Buttons\\WHITE8X8")
    checkMark:SetSize(8, 8)
    checkMark:SetPoint("CENTER")
    checkMark:SetColorTexture(unpack(Shade.Colors.Check))
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
    local enableLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 10, 0)
    enableLabel:SetText("Enable Action Bar Skinning")
    enableLabel:SetTextColor(unpack(Shade.Colors.Text))
    
    yOffset = yOffset - 40
    
    -- Theme dropdown (placeholder for now - only one theme)
    local themeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    themeLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    themeLabel:SetText("Theme: Shade UI")
    themeLabel:SetTextColor(unpack(Shade.Colors.Text))
    
    yOffset = yOffset - 40
    
    -- Border Thickness Slider
    local thicknessSlider = self:CreateSlider(
        panel, 
        "Border Thickness", 
        1, 5, 0.1, 
        self.db.actionbars.borderThickness,
        function(value)
            self.db.actionbars.borderThickness = value
            if self.db.actionbars.enabled then
                self:ApplyActionBarSkins()
            end
        end
    )
    thicknessSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
    yOffset = yOffset - 70
    
    -- Alpha Slider
    local alphaSlider = self:CreateSlider(
        panel,
        "Background Alpha",
        0.1, 1.0, 0.05,
        self.db.actionbars.alpha,
        function(value)
            self.db.actionbars.alpha = value
            if self.db.actionbars.enabled then
                self:ApplyActionBarSkins()
            end
        end
    )
    alphaSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
    yOffset = yOffset - 70
    
    -- Gloss Slider
    local glossSlider = self:CreateSlider(
        panel,
        "Border Glow",
        0.0, 1.0, 0.05,
        self.db.actionbars.gloss,
        function(value)
            self.db.actionbars.gloss = value
            if self.db.actionbars.enabled then
                self:ApplyActionBarSkins()
            end
        end
    )
    glossSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
    yOffset = yOffset - 90
    
    -- Apply and Save buttons
    local applyBtn = self:CreateStyledButton(panel, "Apply", 80, 25)
    applyBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    applyBtn:SetScript("OnClick", function()
        self:ApplySettings()
    end)
    
    local saveBtn = self:CreateStyledButton(panel, "Save", 80, 25)
    saveBtn:SetPoint("LEFT", applyBtn, "RIGHT", 10, 0)
    saveBtn:SetScript("OnClick", function()
        self:SaveProfile()
    end)
    
    -- Info text
    local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("TOPLEFT", applyBtn, "BOTTOMLEFT", 0, -20)
    infoText:SetText("Settings are applied in real-time. Use Apply as fallback, Save to persist changes.")
    infoText:SetTextColor(0.7, 0.7, 0.7, 1)
    infoText:SetWidth(350)
    infoText:SetJustifyH("LEFT")
    
    self.Panels["Actionbars"] = panel
end