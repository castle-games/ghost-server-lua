local Object = require('classic')
local http = require('socket.http')
local pl = require('pl.import_into')()

local log = require('./log')

local GhostClient = Object:extend()

function GhostClient:new(baseUrl, context)
  self.baseUrl = baseUrl or 'http://localhost:8080/api'
  self.context = context or {}
end

function GhostClient:callMethod(method, ...)
  local args = {...}
  -- log(args)
  local url = self.baseUrl .. '/' .. method
  local result =
    http.request(
    {
      url = url,
      method = 'POST',
      headers = {}
    },
    'hello'
  )
  return result
end

return GhostClient
