local pgmoon = require("pgmoon")

local secret = require("./secret")

return pgmoon.new(
    {
        host = secret.postgres.host,
        port = "5432",
        database = secret.postgres.instance,
        password = secret.postgres.password,
        user = secret.postgres.user
    }
)
