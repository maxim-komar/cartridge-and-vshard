local helper = require('test.helper')

local t = require('luatest')
local g = t.group('integration.api')

local CONSTANT = require('app.constant')
local STORAGE_CONSTANT = require('app.storage.constant')

g.before_all = function()
    g.cluster = helper.cluster
    g.cluster:start()
end

g.after_all = function()
    helper.stop_cluster(g.cluster)
end

g.before_each = function()
    helper.truncate_space_on_cluster(g.cluster, STORAGE_CONSTANT.SPACE_NAME)
end

g.test_get_update_delete = function()
    local api_server = g.cluster:server(helper.api_server)

    local ID = 'arbitrary id'
    local DATA = { my_data = { 1, 2, box.NULL }, x = 5, y = 6 }

    do
        local status, result = api_server.net_box:call('get', { ID })
        t.assert_equals(status, CONSTANT.STATUS_OK)
        t.assert_equals(result, nil)
    end

    do
        local status, result = api_server.net_box:call('update', { ID, DATA })
        t.assert_equals(status, CONSTANT.STATUS_OK)
        t.assert_equals(type(result), 'table')
        t.assert_equals(result.data, DATA)
    end

    do
        local status, result = api_server.net_box:call('get', { ID })
        t.assert_equals(status, CONSTANT.STATUS_OK)
        t.assert_equals(type(result), 'table')
        t.assert_equals(result.data, DATA)
    end

    do
        local status, result = api_server.net_box:call('delete', { ID })
        t.assert_equals(status, CONSTANT.STATUS_OK)
        t.assert_equals(type(result), 'table')
        t.assert_equals(result.data, DATA)
    end

    do
        local status, result = api_server.net_box:call('get', { ID })
        t.assert_equals(status, CONSTANT.STATUS_OK)
        t.assert_equals(result, nil)
    end
end
