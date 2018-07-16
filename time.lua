local socket = require('socket')

local log = require('./log')

local _startTimes = {}

-- Returns the epoch time in ms
function now()
  return socket.gettime() * 1000
end

function start()
  local key = {}
  _startTimes[key] = now()
  return key
end

function done(key, label, opts)
  local endTime = now()
  opts = opts or {}
  if label == nil then
    label = 'time'
  end
  local message = opts.message or ''
  local threshold = opts.threshold
  local startTime = _startTimes[key]
  local dt = endTime - startTime
  if (not opts.quiet) and ((not threshold) or dt > threshold) then
    log(label .. ': ' .. math.ceil(dt) .. 'ms ' .. message)
  end
  return dt
end

return {
  now = now,
  start = start,
  done = done
}
