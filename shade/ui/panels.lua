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

function Shade:CreateNavButton(parent, text, index)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(Shade.UI.SidebarWidth - 20, Shade.UI.ButtonHeight)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10 - (index * (Shade.UI.ButtonHeight + 5)))
    
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    button:SetBackdrop(backdrop)
    button:SetBackdropColor(unpack(Shade.Colors.Button))
    button:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Button text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(unpack(Shade.Colors.Text))
    
    -- Hover effects
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(unpack(Shade.Colors.ButtonHover))
        buttonText:SetTextColor(unpack(Shade.Colors.Accent))
    end)
    
    button:SetScript("OnLeave", function()
        if self.CurrentPanel ~= text then
            button:SetBackdropColor(unpack(Shade.Colors.Button))
            buttonText:SetTextColor(unpack(Shade.Colors.Text))
        end
    end)
    
    button.text = buttonText
    self.NavButtons[text] = button
    
    return button
end

function Shade:ShowPanel(panelName)
    -- Hide current panel first
    if self.CurrentPanel and self.Panels[self.CurrentPanel] then
        self.Panels[self.CurrentPanel]:Hide()
        
        -- Reset previous button
        if self.NavButtons[self.CurrentPanel] then
            self.NavButtons[self.CurrentPanel]:SetBackdropColor(unpack(Shade.Colors.Button))
            self.NavButtons[self.CurrentPanel].text:SetTextColor(unpack(Shade.Colors.Text))
        end
    end
    
    -- Create panel if it doesn't exist
    if not self.Panels[panelName] then
        if panelName == "Actionbars" then
            self:CreateActionbarsPanel()
        elseif panelName == "Profiles" then
            self:CreateProfilesPanel()
        end
    end
    
    -- Show new panel
    if self.Panels[panelName] then
        self.Panels[panelName]:Show()
        
        -- Highlight current button
        if self.NavButtons[panelName] then
            self.NavButtons[panelName]:SetBackdropColor(unpack(Shade.Colors.ButtonHover))
            self.NavButtons[panelName].text:SetTextColor(unpack(Shade.Colors.Accent))
        end
    end
    
    self.CurrentPanel = panelName
end

function Shade:CreatePanels()
    -- Panels will be created on-demand
    self.Panels = {}
end

-- Helper function to create styled buttons
function Shade:CreateStyledButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 100, height or Shade.UI.ButtonHeight)
    
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    button:SetBackdrop(backdrop)
    button:SetBackdropColor(unpack(Shade.Colors.Button))
    button:SetBackdropBorderColor(unpack(Shade.Colors.Accent))
    
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(unpack(Shade.Colors.Text))
    
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(unpack(Shade.Colors.ButtonHover))
    end)
    
    button:SetScript("OnLeave", function()
        button:SetBackdropColor(unpack(Shade.Colors.Button))
    end)
    
    return button
end

-- Helper function to create sliders
function Shade:CreateSlider(parent, text, min, max, step, value, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(300, 50)
    
    -- Label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(text)
    label:SetTextColor(unpack(Shade.Colors.Text))
    
    -- Slider
    local slider = CreateFrame("Slider", nil, container, "BackdropTemplate")
    slider:SetSize(200, 20)
    slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(value)
    
    -- Slider backdrop
    local sliderBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    slider:SetBackdrop(sliderBackdrop)
    slider:SetBackdropColor(0.1, 0.1, 0.1, 1)
    slider:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Slider thumb
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetSize(12, 20)
    thumb:SetColorTexture(unpack(Shade.Colors.Slider))
    slider:SetThumbTexture(thumb)
    
    -- Value text
    local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    valueText:SetText(string.format("%.1f", value))
    valueText:SetTextColor(unpack(Shade.Colors.Text))
    
    -- Update on change
    slider:SetScript("OnValueChanged", function(self, val)
        val = tonumber(string.format("%.1f", val))
        valueText:SetText(tostring(val))
        if callback then
            callback(val)
        end
    end)
    
    container.slider = slider
    container.label = label
    container.valueText = valueText
    
    return container
end