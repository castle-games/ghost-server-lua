dofile("set_paths.lua")

local time = require("./time")
local _TK = time.start("request")

local cjson = require("cjson")
local inspect = require("inspect")
local io = require("io")
local lapis = require("lapis")
local config = require("lapis.config")
-- local console = require("lapis.console")
local pl = require('pl.import_into')()


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

app:match(
  "/api/:method(/*)",
  function(self)
    local tk = time.start()
    local m = self.params.method

    local args = {}

    -- URL based params
    if self.params.splat ~= nil then
      local rawArgs = pl.stringx.split(self.params.splat, "/")
      for i, a in ipairs(rawArgs) do
        table.insert(args, interpretArg(a))
      end
    else
      -- Check headers to see if its Lua data
      local contentType = self.req.headers["content-type"]
      local httpMethod = self.req.cmd_mth

      if httpMethod == "POST" then
        local body = ngx.req.read_body()
        local bodyData = ngx.req.get_body_data()
        log(bodyData)
      end
    end

    local result = Api:callMethod(m, args)

    time.done("api." .. m, {key = tk, message = m .. cjson.encode(args)})
    time.done("request", {key = _TK})
    self:write {content_type = "application/x-lua+bitser"}
    return bitser.dumps(result)
  end
)

-- app:match("/console", console.make())

return app
