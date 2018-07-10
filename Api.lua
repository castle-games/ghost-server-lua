local _Api = require("./_Api")
local log = require("./log")

Api = _Api:extend()

function Api:add(a, b)
  log(a, b)
   return a + b
end

function Api:error(type, code, message)
  error(type .. ":" .. code .. ":" .. message)
end

return Api