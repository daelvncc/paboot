--> # pantheon/paboot
--> Small ltext-like library

arrow = (text) ->
  x, y = term.getCursorPos!
  term.setTextColor colors.blue
  term.write "=> #{text}"
  term.setCursorPos x, y+1
  term.setTextColor colors.white

dart = (text) ->
  x, y = term.getCursorPos!
  term.setTextColor colors.cyan
  term.write "-> #{text}"
  term.setCursorPos x, y+1
  term.setTextColor colors.white

title = (text) ->
  x, y = term.getCursorPos!
  term.setTextColor colors.purple
  term.write "== #{text}"
  term.setCursorPos x, y+1
  term.setTextColor colors.white

{ :arrow, :dart, :title }
