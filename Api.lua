local _Api = require("./_Api")

Api = _Api:extend()

function Api:add(a, b)
  return a + b
end

function Api:error(type, code, message)
  error(type .. ":" .. code .. ":" .. message)
end

return Api