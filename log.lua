-- Logs its arguments
-- Use the bare arguments for strings; does an inspect for everything else

local inspect = require("inspect")

function log(...)
  local t = {}
  for i, x in ipairs({...}) do
    if type(x) == 'string' then
      table.insert(t, x)
    else
      table.insert(t, inspect(x))
    end
  end
  io.write(table.concat(t, ' ') .. '\n')
end

return log