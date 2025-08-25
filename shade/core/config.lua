-- Configuration constants for Shade addon
local addonName, Shade = ...

-- UI Colors (SUI-inspired dark theme)
Shade.Colors = {
    Background = {0.137, 0.137, 0.137, 1}, -- #232323
    Accent = {0.541, 0.169, 0.886, 1}, -- Dark purple #8a2be2
    Text = {1, 1, 1, 1}, -- White
    Border = {0.4, 0.1, 0.6, 1}, -- Dark purple border
    Button = {0.2, 0.2, 0.2, 1}, -- Dark button
    ButtonHover = {0.3, 0.3, 0.3, 1}, -- Hover state
    Slider = {0.6, 0.2, 0.8, 1}, -- Slider accent
    Check = {0.541, 0.169, 0.886, 1} -- Checkbox color
}

-- Default settings
Shade.Defaults = {
    actionbars = {
        enabled = true,
        theme = "Shade UI",
        borderThickness = 2,
        alpha = 0.8,
        gloss = 0.3
    }
}

-- Available themes
Shade.Themes = {
    ["Shade UI"] = {
        name = "Shade UI",
        description = "Modern dark theme with purple accents"
    }
}

-- UI Constants
Shade.UI = {
    MainFrameWidth = 600,
    MainFrameHeight = 450,
    SidebarWidth = 150,
    ButtonHeight = 25,
    Spacing = 10,
    BorderSize = 1
}