-- File: shade/core/util.lua

-- Standalone utility module. Does NOT depend on Shade at file load time.

-- Math helpers
local function Clamp01(v) if v < 0 then return 0 elseif v > 1 then return 1 else return v end end

-- Color helpers
function HexToRGB(hex)
  hex = (hex or ""):gsub("#", "")
  if #hex == 3 then
    return tonumber(hex:sub(1,1)..hex:sub(1,1),16)/255,
           tonumber(hex:sub(2,2)..hex:sub(2,2),16)/255,
           tonumber(hex:sub(3,3)..hex:sub(3,3),16)/255
  end
  if #hex < 6 then hex = ("000000"..hex):sub(-6) end
  return tonumber(hex:sub(1,2),16)/255,
         tonumber(hex:sub(3,4),16)/255,
         tonumber(hex:sub(5,6),16)/255
end

local TEX_WHITE = "Interface/Buttons/WHITE8x8"

-- Styling helpers (bound to Shade later)
local function Shade_StylePanel(frame)
  if not frame or not frame.SetBackdrop then return end
  frame:SetBackdrop({ bgFile = TEX_WHITE, edgeFile = TEX_WHITE, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } })
  local r,g,b = HexToRGB("#232323")
  frame:SetBackdropColor(r,g,b,0.98)
  frame:SetBackdropBorderColor(0.42, 0.16, 0.59, 0.9) -- dark purple accent
end

local function Shade_EnsureBorder(host)
  if host.__shadeBorder then return host.__shadeBorder end
  local b = CreateFrame("Frame", nil, host, "BackdropTemplate")
  b:SetFrameLevel(host:GetFrameLevel() + 1)
  b:SetPoint("TOPLEFT", host, -1, 1)
  b:SetPoint("BOTTOMRIGHT", host, 1, -1)
  b:SetBackdrop({ edgeFile = TEX_WHITE, edgeSize = 1 })
  b:SetBackdropBorderColor(0.42, 0.16, 0.59, 0.9)
  host.__shadeBorder = b
  return b
end

local function Shade_EnsureOverlay(host, key, strata)
  key = key or "__shadeOverlay"
  if host[key] then return host[key] end
  local o = CreateFrame("Frame", nil, host)
  o:SetAllPoints(host)
  o:SetFrameStrata(strata or host:GetFrameStrata())
  o:SetFrameLevel(host:GetFrameLevel() + 1)
  local tex = o:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints(o)
  tex:SetTexture(TEX_WHITE)
  o.tex = tex
  host[key] = o
  return o
end

-- Table helpers
function DeepCopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local t = {}
  for k,v in pairs(tbl) do t[k] = DeepCopy(v) end
  return t
end

function DeepMerge(dst, src)
  dst = dst or {}
  for k,v in pairs(src or {}) do
    if type(v) == "table" and type(dst[k]) == "table" then
      DeepMerge(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

-- Base64 + serialize
local b64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64enc(data)
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if #x < 6 then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b64chars:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

local function b64dec(data)
  data = (data or ''):gsub('%s','')
  data = data:gsub('[^'..b64chars..'=]', '')
  return (data:gsub('.', function(x)
    if x == '=' then return '' end
    local r,f='',(b64chars:find(x)-1)
    for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if #x ~= 8 then return '' end
    local c=0
    for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
    return string.char(c)
  end))
end

local function serialize(tbl)
  local t = {}
  local function dump(v)
    local tv = type(v)
    if tv == 'number' then table.insert(t, tostring(v))
    elseif tv == 'boolean' then table.insert(t, v and 'true' or 'false')
    elseif tv == 'string' then table.insert(t, string.format('%q', v))
    elseif tv == 'table' then
      table.insert(t, '{')
      local first = true
      for k,val in pairs(v) do
        if not first then table.insert(t, ',') end
        first = false
        if type(k) == 'string' and k:match('^[_%a][_%w]*$') then
          table.insert(t, k .. '=')
        else
          table.insert(t, '['); dump(k); table.insert(t, ']=')
        end
        dump(val)
      end
      table.insert(t, '}')
    else
      table.insert(t, 'nil')
    end
  end
  dump(tbl)
  return table.concat(t)
end

local function deserialize(str)
  local fn, err = loadstring('return ' .. str)
  if not fn then return nil, err end
  return fn()
end

function SafeCallAfterCombat(fn)
  if InCombatLockdown() then
    if _G.Shade and _G.Shade.DeferSafe then _G.Shade:DeferSafe(fn) else C_Timer.After(0, fn) end
  else
    fn()
  end
end

-- Exports (globals used by other files)
_G.Clamp01 = Clamp01
_G.HexToRGB = HexToRGB
_G.DeepCopy = DeepCopy
_G.DeepMerge = DeepMerge
_G.SafeCallAfterCombat = SafeCallAfterCombat
_G.Shade_StylePanel = Shade_StylePanel
_G.Shade_EnsureBorder = Shade_EnsureBorder
_G.Shade_EnsureOverlay = Shade_EnsureOverlay
function _G.Shade_ExportConfig(tbl) return b64enc(serialize(tbl)) end
function _G.Shade_ImportConfig(str)
  local decoded = b64dec(str)
  if decoded == '' then return nil, 'Invalid data' end
  local ok, res = pcall(deserialize, decoded)
  if not ok then return nil, 'Decode failed' end
  if type(res) ~= 'table' then return nil, 'Wrong type' end
  return res
end
