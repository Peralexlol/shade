-- File: shade/core/profile.lua

local Shade = _G.Shade

-- Export current profile to shareable string
function Shade:ExportProfile()
  local blob = {
    version = self.VERSION,
    profile = DeepCopy(self:GetProfile()),
  }
  return self:ExportConfig(blob)
end

-- Import profile string; returns (ok, messageOrName)
function Shade:ImportProfileString(s)
  local tbl, err = self:ImportConfig(s)
  if not tbl then return false, err end
  if type(tbl.profile) ~= 'table' then return false, 'No profile data' end
  local newName = (tbl.profile.name or 'Imported') .. ' ' .. date('%H%M%S')
  tbl.profile.name = newName
  ShadeDB.global = ShadeDB.global or { profiles = {} }
  ShadeDB.global.profiles[newName] = tbl.profile
  self:SetProfile(newName)
  return true, newName
end

function Shade:CloneProfile(newName)
  if not newName or newName == '' then return false, 'Invalid name' end
  ShadeDB.global = ShadeDB.global or { profiles = {} }
  if ShadeDB.global.profiles[newName] then return false, 'Profile exists' end
  ShadeDB.global.profiles[newName] = DeepCopy(self:GetProfile())
  ShadeDB.global.profiles[newName].name = newName
  return true, newName
end

function Shade:ListProfiles()
  local t = {}
  if not ShadeDB.global or not ShadeDB.global.profiles then return t end
  for name in pairs(ShadeDB.global.profiles) do table.insert(t, name) end
  table.sort(t)
  return t
end
