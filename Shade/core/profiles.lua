--[=[
File: core/Profiles.lua
Simple profiles + import/export (no external libs).
]=]

local Shade = _G.Shade

local b64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64enc(data)
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c + (x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b64chars:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

local function tableSerialize(tbl, indent)
  indent = indent or 0
  local pad = string.rep(' ', indent)
  local out = {'{'}
  for k,v in pairs(tbl) do
    local key = ('[%q]'):format(k)
    if type(k)=='number' then key = '['..k..']' end
    if type(v)=='table' then
      out[#out+1] = ('%s%s=%s,'):format('\n'..pad..' ', key, tableSerialize(v, indent+2))
    elseif type(v)=='string' then
      out[#out+1] = ('%s%s=%q,'):format('\n'..pad..' ', key, v)
    elseif type(v)=='number' or type(v)=='boolean' then
      out[#out+1] = ('%s%s=%s,'):format('\n'..pad..' ', key, tostring(v))
    end
  end
  out[#out+1] = ('\n%s}'):format(pad)
  return table.concat(out)
end

local function safeDeserialize(str)
  if not str or str == '' then return end
  -- Basic guard
  if str:find('[^%w%+/=]') then
    -- looks like base64
    local b=''
    str = str:gsub('[^'..b64chars..'=]','')
    local padding=0
    str:gsub('=','$',function() padding=padding+1 end)
    str=str:gsub('=','')
    local bin=''
    for i=1,#str do
      local c = str:sub(i,i)
      local n = b64chars:find(c)-1
      local bits=''
      for j=6,1,-1 do bits=bits..(n%2^j-n%2^(j-1)>0 and '1' or '0') end
      bin=bin..bits
    end
    local out=''
    for i=1,#bin-((padding*2)+2),8 do out=out..string.char(tonumber(bin:sub(i,i+7),2)) end
    str = out
  end
  -- String should look like a Lua table; forbid keywords
  if str:find('function') or str:find('setfenv') or str:find('loadstring') then return end
  local chunk, err = loadstring('return '..str)
  if not chunk then return end
  setfenv(chunk, {})
  local ok, tbl = pcall(chunk)
  if ok and type(tbl)=='table' then return tbl end
end

local Profiles = {}

function Profiles:Export()
  local p = Shade:GetProfileTable()
  local raw = tableSerialize(p)
  return 'SHADE1:'..b64enc(raw)
end

function Profiles:Import(text)
  if not text then return false,'Empty' end
  text = text:gsub('^SHADE1:','')
  local tbl = safeDeserialize(text)
  if type(tbl)~='table' then return false,'Invalid' end
  -- Replace active profile content
  local prof = Shade:GetProfileTable()
  for k in pairs(prof) do prof[k]=nil end
  for k,v in pairs(tbl) do prof[k]=v end
  Shade:ReapplyAll()
  return true
end

Shade.Profiles = Profiles
