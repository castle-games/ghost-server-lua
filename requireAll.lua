local pl = require('pl.import_into')()
local lfs = require('lfs')

local etc = require('./etc')
local log = require('./log')
local sandbox = require('./sandbox')
local time = require('./time')

local __filename = etc.__filename()
local __dirname = etc.__dirname()

local manifestPath = pl.path.join(__dirname, 'lua_modules/lib/luarocks/rocks/manifest')
local _, manifest = sandbox(manifestPath)

local function varNameForModule(m)
  return m:gsub('%.', '_')
end

local BLACKLIST = {
  lua2json = true,
  ['pl.strict'] = true,
  json2lua = true
}

local function requireModule(m)
  if BLACKLIST[m] then
    -- log('Skipping ' .. m .. '.')
    return
  end
  if string.find(m, '%.') then
    return
  end
  local tk = time.start()
  local name = varNameForModule(m)
  -- print('requiring ' .. m .. '...')
  _G[name] = require(m)
  if name == 'pl' then
    -- local pltk = time.start()
    -- require pl into global
    require(m)
    _G[pl] = require 'pl.import_into'()
  -- time.done(pltk, 'requiring-pl-into-global')
  end
  return time.done(tk, 'require ' .. m, {quiet = true})
end

local function requireAll()
  local _times = {}
  local tk = time.start()
  for m, _ in pairs(manifest.modules) do
    _times[m] = requireModule(m)
  end
  _times.__ALL__ = time.done(tk, 'require-all', {quiet = true})
  return _times
end

local function requireAllAndLog()
  local times = requireAll()
  local s = ''
  local n = 0
  for m, t in pairs(times) do
    if m ~= '__ALL__' then
      n = n + 1
      s = s .. m .. '(' .. math.ceil(t) .. ') '
    end
  end
  log("Required " .. n .. " modules in " .. math.ceil(times.__ALL__).. "ms")
  log(s)
end

-- requireAllAndLog()

return {
  requireAll = requireAll,
  requireAllAndLog = requireAllAndLog,
  manifest = manifest
}
