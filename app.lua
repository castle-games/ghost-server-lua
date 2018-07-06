local time = require('./time')
local _TK = time.start('request')

local inspect = require('inspect')
local io = require('io')
local lapis = require('lapis')
local config = require('lapis.config')
local console = require('lapis.console')

local json = require('./json')
local log = require('./log')
local split = require('./split')

local app = lapis.Application()

local _COUNT = 0

config(
  {'develoment', 'production'},
  {
    measure_performance = true
  }
)

app:get(
  '/',
  function()
    return 'Welcome to Lapis ' .. require('lapis.version')
  end
)

local function interpretArg(s)
  if s == 'nil' then
    return nil
  end
  local n = tonumber(s)
  if n ~= nil then
    return n
  end
  return n
end

app:match(
  '/--/api/:method(/*)',
  function(self)
    local tk = time.start()
    local m = self.params.method

    local args = {}

    -- URL based params
    if self.params.splat ~= nil then
      local rawArgs = split(self.params.splat, '/')
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

    time.done('api.' .. m, {key = tk, message = m .. json.encode(args)})
    time.done('request', { key = _TK})
    return inspect(result)
  end
)

app:match('/console', console.make())

return app
