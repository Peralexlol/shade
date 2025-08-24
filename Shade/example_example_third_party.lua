--[=[
File: example/Example_ThirdParty.lua
Tiny example for authors showing the 2-call API.
Remove this file in production; it's for reference.
]=]

-- Example: inside SomeActionBar addon
-- local Shade = _G.Shade
-- local group = Shade.API:RegisterGroup('SomeActionBar', 'MainBar')
-- for i=1,12 do
--   local button = _G['SomeActionButton'..i]
--   if button then group:AddButton(button, 'ACTION') end
-- end


function API.IterateGroups()
  local out = {}
  for k,g in pairs(Groups) do out[#out+1] = { key=k, addon=g.addon, name=g.name, opts=g.opts, count=#g.buttons } end
  table.sort(out, function(a,b) return a.addon < b.addon or (a.addon==b.addon and a.name<b.name) end)
  return out
end
