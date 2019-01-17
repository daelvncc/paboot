local arrow
arrow = function(text)
  local x, y = term.getCursorPos()
  term.setTextColor(colors.blue)
  term.write("=> " .. tostring(text))
  term.setCursorPos(x, y + 1)
  return term.setTextColor(colors.white)
end
local dart
dart = function(text)
  local x, y = term.getCursorPos()
  term.setTextColor(colors.cyan)
  term.write("-> " .. tostring(text))
  term.setCursorPos(x, y + 1)
  return term.setTextColor(colors.white)
end
local title
title = function(text)
  local x, y = term.getCursorPos()
  term.setTextColor(colors.purple)
  term.write("== " .. tostring(text))
  term.setCursorPos(x, y + 1)
  return term.setTextColor(colors.white)
end
return {
  arrow = arrow,
  dart = dart,
  title = title
}
