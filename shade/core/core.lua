-- Core functions for Shade addon
local addonName, Shade = ...

-- Initialize saved variables and core functionality
function Shade:OnAddonLoaded()
    -- Initialize saved variables with proper structure check
    if not ShadeDB then
        ShadeDB = {
            profile = "Default",
            profiles = {
                Default = {
                    actionbars = {
                        enabled = true,
                        theme = "Shade UI",
                        borderThickness = 2,
                        alpha = 0.8,
                        gloss = 0.3
                    }
                }
            }
        }
    else
        -- Ensure proper structure exists even if ShadeDB exists
        if not ShadeDB.profiles then
            ShadeDB.profiles = {}
        end
        
        if not ShadeDB.profile then
            ShadeDB.profile = "Default"
        end
        
        if not ShadeDB.profiles[ShadeDB.profile] then
            ShadeDB.profiles[ShadeDB.profile] = {
                actionbars = {
                    enabled = true,
                    theme = "Shade UI",
                    borderThickness = 2,
                    alpha = 0.8,
                    gloss = 0.3
                }
            }
        end
        
        -- Ensure actionbars section exists
        if not ShadeDB.profiles[ShadeDB.profile].actionbars then
            ShadeDB.profiles[ShadeDB.profile].actionbars = {
                enabled = true,
                theme = "Shade UI",
                borderThickness = 2,
                alpha = 0.8,
                gloss = 0.3
            }
        end
    end
    
    -- Set current profile reference
    self.db = ShadeDB.profiles[ShadeDB.profile]
    
    self:Print("Loaded successfully. Use /shade to open settings.")
end

function Shade:Initialize()
    -- Ensure db is set (should be set from OnAddonLoaded, but double-check)
    if not self.db then
        self.db = ShadeDB.profiles[ShadeDB.profile]
    end
    
    -- Initialize UI
    self:CreateMainFrame()
    
    -- Initialize modules
    for name, module in pairs(self.modules) do
        if module.Initialize then
            module:Initialize()
        end
    end
    
    -- Apply initial skinning
    self:ApplyActionBarSkins()
end

-- Profile management
function Shade:GetCurrentProfile()
    return self.db
end

function Shade:SaveProfile()
    -- Already automatically saved to ShadeDB
    self:Print("Profile saved.")
end

function Shade:ApplySettings()
    -- Apply all current settings
    self:ApplyActionBarSkins()
    self:Print("Settings applied.")
end

-- Register module
function Shade:RegisterModule(name, module)
    self.modules[name] = module
end