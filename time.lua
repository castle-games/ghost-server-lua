local socket = require('socket')

local log = require('./log')

local _startTimes = {}

-- Returns the epoch time in ms
function now()
  return socket.gettime() * 1000
end

function start(label, key)
  if label == nil then
    label = 'time'
  end
  if key == nil then
    key = label
  end
  if key == true then
    key = {label}
  end
  _startTimes[key] = now()
  return key
end

function done(label, opts)
  local endTime = now()
  if type(label) == 'table' then
    opts = label
    if type(opts.key) == 'table' then
      label = opts.key[1]
    end
  end
  opts = opts or {}
  if label == nil then
    label = 'time'
  end
  local message = opts.message or ''
  local threshold = opts.threshold
  local key = opts.key
  if key == nil then
    key = opts[1]
  end
  if key == nil then
    key = label
  end
  local startTime = _startTimes[key]
  local dt = endTime - startTime
  if (not threshold) or dt > threshold then
    log(label .. ': ' .. dt .. 'ms ' .. message .. '\n')
  end
end

return {
  now = now,
  start = start,
  done = done
}
