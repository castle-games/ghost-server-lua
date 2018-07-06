function split(s, sep)
  local fields = {}
  local sep = sep or '%s'
  local pattern = string.format('([^%s]+)', sep)
  string.gsub(
    s,
    pattern,
    function(c)
      table.insert(fields, c)
    end
  )
  return fields
end


return split
