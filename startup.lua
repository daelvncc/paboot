package.path = table.concat({
  "?",
  "?.lua",
  "?/init.lua",
  "/lib/?",
  "/lib/?.lua",
  "/lib/?/init.lua",
  ".?/?.lua",
  "/rom/apis/?",
  "/rom/apis/?.lua",
  "/rom/apis/?/init.lua",
  "/rom/apis/turtle/?",
  "/rom/apis/turtle/?.lua",
  "/rom/apis/turtle/?/init.lua",
  "/rom/apis/command/?",
  "/rom/apis/command/?.lua",
  "/rom/apis/command/?/init.lua"
}, ";")
_G.require = require
local ltext = require("paboot.ltext")
local PABOOT_VERSION = "0.100"
term.clear()
term.setTextColor(colors.cyan)
ltext.title("paboot " .. tostring(PABOOT_VERSION))
ltext.arrow("Starting up...")
table.copy = function(orig, hasht)
  if hasht == nil then
    hasht = { }
  end
  local origT = type(orig)
  local copy
  if origT == "table" then
    if hasht[orig] then
      copy = orig
    else
      hasht[orig] = true
      copy = { }
      for origk, origv in next,orig,nil do
        copy[table.copy(origk)] = table.copy(origv, hasht)
      end
      setmetatable(copy, table.copy(getmetatable(orig)))
    end
  else
    copy = orig
  end
  return copy
end
ltext.dart("Registered table.copy")
ltext.arrow("Processing entries")
local entries_atroot = fs.find("/paboot.*")
local entries_below = fs.find("/*/paboot.*")
local entryl = { }
for i = 1, #entries_atroot do
  ltext.dart(entries_atroot[i])
  local entryenv = table.copy(_G)
  local entryf, err = loadfile(entries_atroot[i], entryenv)
  if not (entryf) then
    error("paboot $ could not load entry " .. tostring(entries_atroot[i]) .. ": " .. tostring(err))
  end
  entryf()
  table.insert(entryl, entryenv)
end
for i = 1, #entries_below do
  ltext.dart(entries_below[i])
  local entryenv = table.copy(_G)
  local entryf, err = loadfile(entries_below[i], entryenv)
  if not (entryf) then
    error("paboot $ could not load entry " .. tostring(entries_felow[i]) .. ": " .. tostring(err))
  end
  entryf()
  table.insert(entryl, entryenv)
end
local entry_textl = { }
for _index_0 = 1, #entryl do
  local entry = entryl[_index_0]
  table.insert(entry_textl, tostring(entry.name) .. " (" .. tostring(entry.arch) .. ") in " .. tostring(entry.entrypoint))
end
ltext.arrow("Processing UI...")
local sx, sy = term.getSize()
local pointer = 1
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
paintutils.drawBox(2, 2, sx - 1, sy - 3, colors.white)
paintutils.drawBox(3, 2 + pointer, sx - 2, 3, colors.gray)
term.setBackgroundColor(colors.black)
term.setCursorPos(2, 1)
term.write("paboot " .. tostring(PABOOT_VERSION))
local redraw_text
redraw_text = function()
  for i = 1, #entry_textl do
    term.setCursorPos(3, 2 + i)
    if i == pointer then
      paintutils.drawBox(3, 2 + i, sx - 2, 2 + i, colors.gray)
    else
      paintutils.drawBox(3, 2 + i, sx - 2, 2 + i, colors.black)
    end
    term.setCursorPos(3, 2 + i)
    term.write(entry_textl[i])
    term.setBackgroundColor(colors.black)
  end
end
local process_keys
process_keys = function()
  local event, key
  while true do
    event, key = os.pullEvent("key")
    if event then
      break
    end
  end
  if key == keys.down then
    pointer = pointer + 1
    if pointer > #entry_textl then
      pointer = 1
    end
  elseif key == keys.up then
    pointer = pointer - 1
    if pointer < 1 then
      pointer = #entry_textl
    end
  elseif key == keys.enter then
    return true
  end
end
while true do
  redraw_text()
  if process_keys() then
    break
  end
end
term.setCursorPos(1, sy - 2)
print("Running " .. entryl[pointer].entrypoint)
return os.run((table.copy(_G)), entryl[pointer].entrypoint)
