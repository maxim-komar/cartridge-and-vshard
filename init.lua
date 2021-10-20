#!/usr/bin/env tarantool

require('strict').on()

-- configure path so that you can run application
-- from outside the root directory
if package.setsearchroot ~= nil then
    package.setsearchroot()
end

-- configure cartridge

local cartridge = require('cartridge')

local ok, err = cartridge.cfg({
    roles = {
        'cartridge.roles.vshard-storage',
        'cartridge.roles.vshard-router',
        'app.roles.api',
        'app.roles.storage',
    },
})

assert(ok, tostring(err))
