require('strict').on()

local cartridge = require('cartridge')

local CONSTANT = require('app.constant')

local function get(id)
    if id == nil then
        return CONSTANT.STATUS_UNDEFINED_PARAM, 'id'
    end

    local router = cartridge.service_get('vshard-router').get()
    local bucket_id = router:bucket_id_strcrc32(id)

    -- local res, err = err_vshard_router:pcall(
    local ok, data_or_err = pcall(
        router.call,
        router,
        bucket_id,
        'read',
        'get_by_id',
        { id },
        { timeout = CONSTANT.REQUEST_TIMEOUT }
    )

    if not ok then
        return CONSTANT.STATUS_REQUEST_ERROR, data_or_err
    end

    return CONSTANT.STATUS_OK, data_or_err
--    if err then
--        return CONSTANT.STATUS_REQUEST_ERROR, err
--    end
--
--    return CONSTANT.STATUS_OK, res
end

local function update(id, data)
    if id == nil then
        return CONSTANT.STATUS_UNDEFINED_PARAM, 'id'
    end

    if data == nil then
        return CONSTANT.STATUS_UNDEFINED_PARAM, 'data'
    end

    local router = cartridge.service_get('vshard-router').get()
    local bucket_id = router:bucket_id_strcrc32(id)

    local ok, data_or_err = pcall(
    -- local res, err = err_vshard_router:pcall(
        router.call,
        router,
        bucket_id,
        'write',
        'update_by_id',
        { id, bucket_id, data },
        { timeout = CONSTANT.REQUEST_TIMEOUT }
    )

    if not ok then
        return CONSTANT.STATUS_REQUEST_ERROR, data_or_err
    end

    return CONSTANT.STATUS_OK, data_or_err

--    if err then
--        return CONSTANT.STATUS_REQUEST_ERROR, err
--    end
--
--    return CONSTANT.STATUS_OK, res
end

local function delete(id)
    if id == nil then
        return CONSTANT.STATUS_UNDEFINED_PARAM, 'id'
    end

    local router = cartridge.service_get('vshard-router').get()
    local bucket_id = router:bucket_id_strcrc32(id)

    local ok, data_or_err = pcall(
    -- local res, err = err_vshard_router:pcall(
        router.call,
        router,
        bucket_id,
        'write',
        'delete_by_id',
        { id },
        { timeout = CONSTANT.REQUEST_TIMEOUT }
    )

    if not ok then
        return CONSTANT.STATUS_REQUEST_ERROR, data_or_err
    end

    return CONSTANT.STATUS_OK, data_or_err
--    if err then
--        return CONSTANT.STATUS_REQUEST_ERROR, err
--    end
--
--    return CONSTANT.STATUS_OK, res
end

local API_FUNCTIONS = {
    {'get',    get},
    {'update', update},
    {'delete', delete},
}

local function init(opts)
    if opts.is_master then
        box.schema.role.create(CONSTANT.ROLE_API, { if_not_exists = true })
    end

    for _, v in pairs(API_FUNCTIONS) do
        local name, func = unpack(v)

        if opts.is_master then
            box.schema.func.create(name, { if_not_exists = true })
            box.schema.role.grant(
                CONSTANT.ROLE_API,
                'execute',
                'function',
                name,
                { if_not_exists = true }
            )
        end

        rawset(_G, name, func)
    end
end

return {
    role_name = 'app.roles.api',

    init = init,

    dependencies = {
        'cartridge.roles.vshard-router'
    },
}
