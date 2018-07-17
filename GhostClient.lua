local cjson = require("cjson")
local Object = require("classic")
local http = require("socket.http")
local ltn12 = require("ltn12")
local pl = require("pl.import_into")()

local bitser = require("./bitser")

local log = require("./log")

local GhostClient = Object:extend()

function GhostClient:new(baseUrl, context)
  self.baseUrl = baseUrl or "http://localhost:8080/api"
  self.context = context or {}
end

function GhostClient:callMethod(method, ...)
  local args = {...}
  -- log(args)
  local url = self.baseUrl
  local data = {method = method, args = args, context = {}}
  local bodyData = bitser.dumps(data)
  -- local bodyData = cjson.encode(data)
  local respbody = {} -- for the response body
  local result, respcode, respheaders, respstatus = http.request(
    {
      url = url,
      method = "POST",
      headers = {
        ["Content-Type"] = "application/x-lua+bitser",
        -- ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#bodyData)
      },
      source = ltn12.source.string(bodyData),
      sink = ltn12.sink.table(respbody)
    }
  )
  -- return result, respcode, respheaders, respstatus, respbody
  return bitser.loads(respbody[1])
end

g = GhostClient()

return GhostClient
