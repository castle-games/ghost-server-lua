local pl = require 'pl.import_into'()

function __filename()
  local f = debug.getinfo(2, 'S').source:sub(2)
  if f == '[C]' then
    return nil
  end
  return pl.path.abspath(f)
end

function __dirname()
  return pl.path.dirname(__filename())
end

function isMain()
  return (debug.getinfo(4) == nil)
end

return {
  __filename = __filename,
  __dirname = __dirname,
  starsWith = startsWith,
  isMain = isMain
}
