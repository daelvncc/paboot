--> # pantheon/paboot
--> Pantheon Bootloader
-- By daelvn
-- 15.01.2019

--> Set global package.path
package.path = table.concat {
  "?"
  "?.lua"
  "?/init.lua"
  "/lib/?"
  "/lib/?.lua"
  "/lib/?/init.lua"
  ---
  ".?/?.lua"
  --
  "/rom/apis/?"
  "/rom/apis/?.lua"
  "/rom/apis/?/init.lua"
  "/rom/apis/turtle/?"
  "/rom/apis/turtle/?.lua"
  "/rom/apis/turtle/?/init.lua"
  "/rom/apis/command/?"
  "/rom/apis/command/?.lua"
  "/rom/apis/command/?/init.lua"
}, ";"
_G.require     = require
ltext          = require "paboot.ltext"
PABOOT_VERSION = "0.100"
--
term.clear!
term.setTextColor colors.cyan
ltext.title "paboot #{PABOOT_VERSION}"
ltext.arrow "Starting up..."

--> # Concept
--> The idea behind this bootloader is to containerize the OS or program it will boot, and
--> is adaptable to any environment, including non-Pantheon environments. However, there
--> might be better results in the future if using a pavfsl device structure.

--> # table.copy
--> Use a function to create a copy of the global environment trying to avoid referencing
--> as much as possible so that we have some kind of "sandbox". Containers will be able to
--> communicate via the paboot-provided container API.
table.copy = (orig, hasht={}) ->
  origT = type orig
  local copy
  if origT == "table"
    if hasht[orig]
      copy = orig
    else
      hasht[orig] = true
      copy        = {}
      for origk, origv in next, orig, nil
        copy[table.copy origk] = table.copy origv, hasht
      setmetatable copy, table.copy getmetatable orig
  else
    copy = orig
  --
  copy
ltext.dart "Registered table.copy"

--> # Entries
--> Entries in the format `paboot.*` will be searched across / and only once into the directories
--> to ensure compatibility between systems.
ltext.arrow "Processing entries"
entries_atroot = fs.find "/paboot.*"
entries_below  = fs.find "/*/paboot.*"
entryl         = {}
for i=1,#entries_atroot
  ltext.dart entries_atroot[i]
  entryenv    = table.copy _G
  entryf, err = loadfile entries_atroot[i], entryenv
  unless entryf then error "paboot $ could not load entry #{entries_atroot[i]}: #{err}"
  entryf!
  table.insert entryl, entryenv
for i=1,#entries_below
  ltext.dart entries_below[i]
  entryenv    = table.copy _G
  entryf, err = loadfile entries_below[i], entryenv
  unless entryf then error "paboot $ could not load entry #{entries_felow[i]}: #{err}"
  entryf!
  table.insert entryl, entryenv
--> Generating the entry texts
entry_textl = {}
for entry in *entryl
  table.insert entry_textl, "#{entry.name} (#{entry.arch}) in #{entry.entrypoint}"

--> # UI
ltext.arrow "Processing UI..."
sx, sy  = term.getSize!
pointer = 1
--
term.setBackgroundColor colors.black
term.setTextColor       colors.white
term.clear!
--
paintutils.drawBox 2, 2,         sx-1, sy-3, colors.white
paintutils.drawBox 3, 2+pointer, sx-2, 3,    colors.gray
term.setBackgroundColor colors.black
--
term.setCursorPos 2, 1
term.write "paboot #{PABOOT_VERSION}"
--
redraw_text = ->
  for i=1, #entry_textl
    term.setCursorPos 3, 2+i
    if i == pointer
      paintutils.drawBox 3, 2+i, sx-2, 2+i, colors.gray
    else
      paintutils.drawBox 3, 2+i, sx-2, 2+i, colors.black
    term.setCursorPos 3,2+i
    term.write entry_textl[i]
    term.setBackgroundColor colors.black
--
process_keys = ->
  local event, key
  while true do
    event, key = os.pullEvent "key"
    if event then break
  if key == keys.down
    pointer += 1
    if pointer > #entry_textl then pointer = 1
  elseif key == keys.up
    pointer -= 1
    if pointer < 1 then pointer = #entry_textl
  elseif key == keys.enter
    return true
--
while true do
  redraw_text!
  if process_keys! then break
--> Execute the picked entrypoint
term.setCursorPos 1, sy-2
print "Running " .. entryl[pointer].entrypoint
os.run (table.copy _G), entryl[pointer].entrypoint
