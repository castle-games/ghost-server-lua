local _Api = require("./_Api")
local log = require("./log")
local pg = require("./pg")

Api = _Api:extend()

function Api:add(a, b)
  return a + b
end

function Api:listPeople()
  return pg:query("SELECT * FROM people")
end

function Api:error(type, code, message)
  error(type .. ":" .. code .. ":" .. message)
end

return Api
