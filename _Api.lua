local Object = require("./classic")

local _Api = Object:extend()

function _Api:new(context)
  self.context = context
  self.response = {
    result = nil,
    error = nil,
    data = {},
    cmd = {}
  }
end

local function startsWith(s, prefix)
  if type(s) ~= "string" then
    return false
  end
  return string.sub(s, 1, string.len(prefix)) == prefix
end

local function slice(t, start, fin)
  return {table.unpack(t, start, fin)}
end

function _Api:callMethod(method, args)
  if not self.response then
    self.response = {}
  end
  
  if startsWith(method, "_") or method == "super" or _Api[method] ~= nil then
    self.response.error = {
      type = "API_ERROR",
      code = "RESERVED_METHOD_NAME",
      message = "The method `" .. method .. "` is a reserved method name",
      props = {
        method = method
      }
    }
    return self.response
  end

  if not Api[method] then
    self.response.error = {
      type = "API_ERROR",
      code = "NOT_IMPLEMENTED",
      message = "No such method `" .. method .. "` in the API",
      props = {
        method = method
      }
    }
    return self.response
  end

  local ok, resultOrErr = pcall(Api[method], self, table.unpack(args))
  if ok then
    self.response.result = resultOrErr
    self.response.error = nil
  else
    local start, fin = string.find(resultOrErr, ": ")
    local err = string.sub(resultOrErr, fin + 1)

    local pos, len = string.find(err, "[%u%d_%d:]+:")
    if pos == nil or pos ~= 1 then
      self.response.error = {
        type = nil,
        code = nil,
        message = resultOrErr,
        props = nil
      }
    else
      local prefix = string.sub(err, pos, len)
      local rest = string.sub(err, pos + len)
      local parts = split(prefix, ":")
      if #parts == 1 then
        self.response.error = {
          type = parts[1],
          code = nil,
          message = rest
        }
      elseif #parts == 2 then
        self.response.error = {
          type = parts[1],
          code = parts[2],
          message = rest,
          props = nil
        }
      else
        self.response.error = {
          type = parts[1],
          code = parts[2],
          message = rest,
          etc = slice(parts, 3),
          props = nil
        }
      end
    end
  end
  return self.response
end

function _Api:setData(key, val)
  if type(key) == "table" then
    for k, v in pairs(key) do
      self:setData(k, v)
    end
    return
  else
    self.response.data[key] = val
  end
end

function _Api:addCommand(cmd)
  table.insert(self.response.data, cmd)
end

return _Api
