-- Profiles module for Shade addon
local addonName, Shade = ...

function Shade:CreateProfilesPanel()
    if self.Panels["Profiles"] then return end
    
    local content = self.MainFrame.content
    local panel = CreateFrame("Frame", nil, content)
    panel:SetAllPoints(content)
    panel:Hide()
    
    -- Panel title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -20)
    title:SetText("Profiles")
    title:SetTextColor(unpack(Shade.Colors.Text))
    
    local yOffset = -60
    
    -- Export section
    local exportLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    exportLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    exportLabel:SetText("Export Profile")
    exportLabel:SetTextColor(unpack(Shade.Colors.Text))
    
    yOffset = yOffset - 30
    
    local exportBtn = self:CreateStyledButton(panel, "Generate Export Code", 150, 25)
    exportBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
    -- Export text box
    local exportBox = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    exportBox:SetSize(350, 80)
    exportBox:SetPoint("TOPLEFT", exportBtn, "BOTTOMLEFT", 0, -10)
    
    -- Style the export box
    exportBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    exportBox:SetBackdropColor(0.05, 0.05, 0.05, 1)
    exportBox:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Create the actual EditBox inside
    local exportEditBox = CreateFrame("EditBox", nil, exportBox)
    exportEditBox:SetPoint("TOPLEFT", exportBox, "TOPLEFT", 5, -5)
    exportEditBox:SetPoint("BOTTOMRIGHT", exportBox, "BOTTOMRIGHT", -5, 5)
    exportEditBox:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    exportEditBox:SetTextColor(unpack(Shade.Colors.Text))
    exportEditBox:SetText("Click 'Generate Export Code' to create shareable profile data.")
    exportEditBox:SetMultiLine(true)
    exportEditBox:SetAutoFocus(false)
    exportEditBox:EnableMouse(true)
    
    -- Make it easier to select all text
    exportEditBox:SetScript("OnMouseDown", function(self)
        self:HighlightText()
    end)
    
    exportBtn:SetScript("OnClick", function()
        local exportData = self:ExportProfile()
        exportEditBox:SetText(exportData)
        exportEditBox:HighlightText()
    end)
    
    yOffset = yOffset - 120
    
    -- Import section
    local importLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    importLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    importLabel:SetText("Import Profile")
    importLabel:SetTextColor(unpack(Shade.Colors.Text))
    
    yOffset = yOffset - 30
    
    -- Import text box
    local importBox = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    importBox:SetSize(350, 80)
    importBox:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    
    -- Style the import box
    importBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    importBox:SetBackdropColor(0.05, 0.05, 0.05, 1)
    importBox:SetBackdropBorderColor(unpack(Shade.Colors.Border))
    
    -- Create the actual EditBox inside
    local importEditBox = CreateFrame("EditBox", nil, importBox)
    importEditBox:SetPoint("TOPLEFT", importBox, "TOPLEFT", 5, -5)
    importEditBox:SetPoint("BOTTOMRIGHT", importBox, "BOTTOMRIGHT", -5, 5)
    importEditBox:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    importEditBox:SetTextColor(unpack(Shade.Colors.Text))
    importEditBox:SetText("Paste profile code here...")
    importEditBox:SetMultiLine(true)
    importEditBox:SetAutoFocus(false)
    importEditBox:EnableMouse(true)
    
    yOffset = yOffset - 90
    
    local importBtn = self:CreateStyledButton(panel, "Import Profile", 100, 25)
    importBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
    importBtn:SetScript("OnClick", function()
        local success = self:ImportProfile(importEditBox:GetText())
        if success then
            self:Print("Profile imported successfully!")
            -- Refresh UI
            if self.Panels["Actionbars"] then
                self.Panels["Actionbars"]:Hide()
                self.Panels["Actionbars"] = nil
                self:CreateActionbarsPanel()
            end
            self:ApplyActionBarSkins()
        else
            self:Print("Failed to import profile. Please check the code.")
        end
    end)
    
    -- Clear button for import box
    local clearBtn = self:CreateStyledButton(panel, "Clear", 60, 25)
    clearBtn:SetPoint("LEFT", importBtn, "RIGHT", 10, 0)
    clearBtn:SetScript("OnClick", function()
        importEditBox:SetText("")
        importEditBox:SetFocus()
    end)
    
    -- Info text
    local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 0, -20)
    infoText:SetText("Share your profile codes with friends! Export creates a code you can copy, import applies a code to your settings.")
    infoText:SetTextColor(0.7, 0.7, 0.7, 1)
    infoText:SetWidth(350)
    infoText:SetJustifyH("LEFT")
    
    self.Panels["Profiles"] = panel
end

-- Export current profile to encoded string
function Shade:ExportProfile()
    local profileData = {
        version = "1.0",
        actionbars = {
            enabled = self.db.actionbars.enabled,
            theme = self.db.actionbars.theme,
            borderThickness = self.db.actionbars.borderThickness,
            alpha = self.db.actionbars.alpha,
            gloss = self.db.actionbars.gloss
        }
    }
    
    -- Simple serialization (you could use a library like LibSerialize for more complex data)
    local serialized = self:SerializeTable(profileData)
    
    -- Base64 encode (simplified version)
    local encoded = self:EncodeBase64(serialized)
    
    return "SHADE:" .. encoded
end

-- Import profile from encoded string
function Shade:ImportProfile(importString)
    if not importString or not importString:match("^SHADE:") then
        return false
    end
    
    local encoded = importString:gsub("^SHADE:", "")
    local serialized = self:DecodeBase64(encoded)
    
    if not serialized then
        return false
    end
    
    local success, profileData = pcall(self.DeserializeTable, self, serialized)
    
    if not success or not profileData or profileData.version ~= "1.0" then
        return false
    end
    
    -- Apply imported settings
    if profileData.actionbars then
        for key, value in pairs(profileData.actionbars) do
            if self.db.actionbars[key] ~= nil then
                self.db.actionbars[key] = value
            end
        end
    end
    
    return true
end

-- Simple table serialization
function Shade:SerializeTable(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and '["' .. k .. '"]' or "[" .. k .. "]"
        local value
        if type(v) == "table" then
            value = self:SerializeTable(v)
        elseif type(v) == "string" then
            value = '"' .. v .. '"'
        elseif type(v) == "boolean" then
            value = v and "true" or "false"
        else
            value = tostring(v)
        end
        result = result .. key .. "=" .. value .. ","
    end
    result = result:gsub(",$", "") .. "}"
    return result
end

-- Simple table deserialization
function Shade:DeserializeTable(str)
    local func = loadstring("return " .. str)
    if func then
        return func()
    end
    return nil
end

-- Simple Base64 encoding (basic implementation)
function Shade:EncodeBase64(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i+2)
        b = b or 0
        c = c or 0
        
        local bitmap = a * 0x10000 + b * 0x100 + c
        
        for j = 18, 0, -6 do
            local index = math.floor(bitmap / 2^j) % 64 + 1
            result = result .. chars:sub(index, index)
        end
    end
    
    local padding = #data % 3
    if padding > 0 then
        result = result:sub(1, -(4 - padding)) .. string.rep("=", 4 - padding)
    end
    
    return result
end

-- Simple Base64 decoding
function Shade:DecodeBase64(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    data = data:gsub("[^" .. chars .. "=]", "")
    
    local result = ""
    
    for i = 1, #data, 4 do
        local chunk = data:sub(i, i+3)
        local a, b, c, d = chunk:byte(1, 4)
        
        a = chars:find(string.char(a)) - 1
        b = chars:find(string.char(b)) - 1
        c = c and (chars:find(string.char(c)) - 1) or 0
        d = d and (chars:find(string.char(d)) - 1) or 0
        
        local bitmap = a * 0x40000 + b * 0x1000 + c * 0x40 + d
        
        result = result .. string.char(math.floor(bitmap / 0x10000) % 0x100)
        if chunk:sub(3,3) ~= "=" then
            result = result .. string.char(math.floor(bitmap / 0x100) % 0x100)
        end
        if chunk:sub(4,4) ~= "=" then
            result = result .. string.char(bitmap % 0x100)
        end
    end
    
    return result
end