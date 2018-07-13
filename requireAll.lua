local pl = require "pl.import_into"()
local lfs = require("lfs")

local etc = require("./etc")

local __filename = etc.__filename()
local __dirname = etc.__dirname()



print(__filename, __dirname)