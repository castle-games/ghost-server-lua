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
  return m:gsub('%.', '_'):gsub('%-', '_')
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

local function stripLuaExtension(p)
  return p:sub(1, #p - 4)
end

local function varNameForFile(p)
  -- strip .lua extension
  local name = stripLuaExtension(pl.path.basename(p))
  if name == 'init' then
    name = varNameForModule(pl.path.basename(pl.path.dirname(p)))
  end
  return name
end

local function getLuaFiles()
  local tk = time.start()
  local fl = pl.List({})
  local filesInThisDir = pl.dir.getfiles('.', '*.lua')
  fl:extend(filesInThisDir)

  local DIRECTORY_BLACKLIST = {
    lua_modules = true
  }
  local directories = pl.dir.getdirectories(__dirname)
  for _, d in ipairs(directories) do
    if not DIRECTORY_BLACKLIST[d] then
      local files = pl.dir.getfiles(d, '*.lua')
      fl:extend(files)
    end
  end
  time.done(tk, 'get-lua-files')
  return fl
end

local function requireLuaFiles()
  local files = getLuaFiles()
  local times = {}
  local BLACKLIST = {
    set_paths = true
    -- requireAll = true,
    -- Api = true,
    -- secret = true,
    -- log = true,
    -- etc = true,
  }
  for _, p in ipairs(files) do
    local v = varNameForFile(p)
    if not BLACKLIST[v] then
      local rn = stripLuaExtension(pl.path.relpath(p, __dirname))
      local tk = time.start()
      -- log('require ' .. v .. ' from ' .. rn)
      _G[v] = require(rn)
      times[v] = time.done(tk, 'require-' .. v, {quiet = true})
    end
  end
  return times
end

local function requireAllAndLog()
  local allTk = time.start()
  local times = requireAll()
  local s = ''
  local n = 0
  for m, t in pairs(times) do
    if m ~= '__ALL__' then
      n = n + 1
      s = s .. m .. '(' .. math.ceil(t) .. ') '
    end
  end
  log('Required ' .. n .. ' modules in ' .. math.ceil(times.__ALL__) .. 'ms')
  log(s)

  local tk = time.start()
  local times2 = requireLuaFiles()
  local allTime = time.done(tk, 'require-all-files', {quiet = true})
  local s = ''
  local n = 0
  for m, t in pairs(times2) do
    s = s .. m .. '(' .. math.ceil(t) .. ') '
    n = n + 1
  end
  log('Required ' .. n .. ' files in ' .. math.ceil(allTime) .. 'ms')
  log(s)
  local combinedTime = time.done(allTk, 'require-all-combined', {quiet = true})
  log(math.ceil(combinedTime) .. 'ms')
end

-- requireAllAndLog()

return {
  requireAll = requireAll,
  requireAllAndLog = requireAllAndLog,
  manifest = manifest,
  getLuaFiles = getLuaFiles
}
