function sandbox(fn, env)
  env = env or {}
  local f, e = loadfile(fn)
  if not f then
    error(e, 2)
  end
  setfenv(f, env)
  return f(), env
end

return sandbox
