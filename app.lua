dofile("set_paths.lua")

local time = require("./time")
local _TK = time.start("request")

local cjson = require("cjson")
local inspect = require("inspect")
local io = require("io")
local lapis = require("lapis")
local config = require("lapis.config")
-- local console = require("lapis.console")
local pl = require("pl.import_into")()

local Api = require("./Api")
local bitser = require("./bitser")
local log = require("./log")

local app = lapis.Application()

local _COUNT = 0

config(
  {"develoment", "production"},
  {
    measure_performance = true
  }
)

app:get(
  "/",
  function()
    return "Welcome to Lapis " .. require("lapis.version")
  end
)

local function interpretArg(s)
  if s == "nil" then
    return nil
  end
  local n = tonumber(s)
  if n ~= nil then
    return n
  end
  return n
end

local function handleApiRequest(self)
  local body = ngx.req.read_body()
  local bodyData = ngx.req.get_body_data()
  local contentType = self.req.headers["content-type"]

  local data
  if contentType == "application/json" then
    data = cjson.decode(bodyData)
  elseif contentType == "application/x-lua+bitser" then
    data = bitser.loads(bodyData)
  else
    error("Use content-type application/json or application/x-lua+bitser")
  end

  local tk = time.start()
  a = Api(data.context)
  local response = a:callMethod(data.method, data.args)
  time.done(tk, "api." .. data.method .. cjson.encode(data.args))

  if contentType == "application/json" then
    return {json = response}
  elseif contentType == "application/x-lua+bitser" then
    return {
      content_type = "application/x-lua+bitser",
      layout = false,
      bitser.dumps(response)
    }
  else
    error("Use content-type application/json or application/x-lua+bitser")
  end
end

app:post(
  "/api",
  function(self)
    local ok, errOrResult =
      pcall(
      function()
        return handleApiRequest(self)
      end
    )
    if ok then
      return errOrResult
    else
      -- TODO: Handle client error type things
      log("An error: " .. errOrResult)
      return {
        status = 500,
        json = "An error occurred: " .. errOrResult
      }
    end
  end
)

return app
