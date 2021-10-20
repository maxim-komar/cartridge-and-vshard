-- This file is required automatically by luatest.
-- Add common configuration here.

local fio = require('fio')
local t = require('luatest')
local cartridge_helpers = require('cartridge.test-helpers')

local helper = {}

helper.root = fio.dirname(fio.abspath(package.search('init')))
helper.datadir = fio.pathjoin(helper.root, 'tmp', 'db_test')
helper.server_command = fio.pathjoin(helper.root, 'init.lua')

helper.api_server = 'api-1'

helper.cluster = cartridge_helpers.Cluster:new({
    server_command = helper.server_command,
    datadir        = helper.datadir,
    use_vshard     = true,
    replicasets    = {
        {
            alias   = 'storage-1',
            uuid    = cartridge_helpers.uuid(1),
            roles   = {'app.roles.storage'},
            servers = {
                { instance_uuid = cartridge_helpers.uuid(1, 'a'), alias = 'storage-1a' },
                { instance_uuid = cartridge_helpers.uuid(1, 'b'), alias = 'storage-1b' },
            }
        },

        {
            alias   = 'storage-2',
            uuid    = cartridge_helpers.uuid(2),
            roles   = {'app.roles.storage'},
            servers = {
                { instance_uuid = cartridge_helpers.uuid(2, 'a'), alias = 'storage-2a' },
                { instance_uuid = cartridge_helpers.uuid(2, 'b'), alias = 'storage-2b' },
            }
        },

        {
            alias   = 'api',
            uuid    = cartridge_helpers.uuid('f'),
            roles   = {'app.roles.api'},
            servers = {
                { instance_uuid = cartridge_helpers.uuid('f', 1), alias = helper.api_server },
            },
        },
    }
})

function helper.truncate_space_on_cluster(cluster, space_name)
    assert(cluster ~= nil)
    for _, server in ipairs(cluster.servers) do
        server.net_box:eval([[
            local space_name = ...
            local space = box.space[space_name]
            if space ~= nil and not box.cfg.read_only then
                space:truncate()
            end
        ]], {space_name})
    end
end

function helper.drop_space_on_cluster(cluster, space_name)
    assert(cluster ~= nil)
    for _, server in ipairs(cluster.servers) do
        server.net_box:eval([[
            local space_name = ...
            local space = box.space[space_name]
            if space ~= nil and not box.cfg.read_only then
                space:drop()
            end
        ]], {space_name})
    end
end

function helper.stop_cluster(cluster)
    assert(cluster ~= nil)
    cluster:stop()
    fio.rmtree(cluster.datadir)
end

t.before_suite(function()
    fio.rmtree(helper.datadir)
    fio.mktree(helper.datadir)
    box.cfg({work_dir = helper.datadir})
end)

return helper
