-- File: Shade/core/safe.lua
-- Encoding: UTF-8 (no BOM). ASCII-only.
-- Purpose: Global safeguard so ANY CheckButton created by Shade or other modules
--          won't crash if a bad Set*Texture(arg) is called with a color table/number.

local Shade = _G.Shade or {}
if not _G.Shade then _G.Shade = Shade end
Shade.Safe = Shade.Safe or {}

local function guardSetters(obj)
  if obj.__shade_guarded then return end
  local methods = {
    "SetNormalTexture",
    "SetPushedTexture",
    "SetHighlightTexture",
    "SetCheckedTexture",
  }
  for _, m in ipairs(methods) do
    local orig = obj[m]
    if type(orig) == "function" then
      obj[m] = function(self, asset)
        local ty = type(asset)
        if asset == nil or ty == "string" or ty == "userdata" then
          return orig(self, asset)
        end
        if not self.__shade_tex_warned then
          print("|cff8059f2Shade|r: Ignored invalid "..m.." arg type '"..ty.."' on CheckButton.")
          self.__shade_tex_warned = true
        end
      end
    end
  end
  obj.__shade_guarded = true
end

function Shade.Safe.Guard(obj)
  if obj and obj.GetObjectType and obj:GetObjectType() == "CheckButton" then
    guardSetters(obj)
  end
end

-- Lightweight CreateFrame hook (post-call) to guard any CheckButton globally
local _CreateFrame = CreateFrame
CreateFrame = function(frameType, ...)
  local f = _CreateFrame(frameType, ...)
  if frameType == "CheckButton" and f then
    guardSetters(f)
  end
  return f
end
