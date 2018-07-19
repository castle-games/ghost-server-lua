local pgmoon = require("pgmoon")

local secret = require("./secret")
local time = require("./time")

local pg =
    pgmoon.new(
    {
        host = secret.postgres.host,
        port = "5432",
        database = secret.postgres.instance,
        password = secret.postgres.password,
        user = secret.postgres.user
    }
)

local _query = pg.query
pg.query = function(self, q, ...)
    local tk = time.start()
    local result = _query(self, q, ...)
    time.done(tk, "pg-query", {message = q})
    return result
end

return pg
