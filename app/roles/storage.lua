require('strict').on()

local STORAGE_CONSTANT = require('app.storage.constant')

local function init_space()
    local space = box.schema.space.create(STORAGE_CONSTANT.SPACE_NAME, {
        if_not_exists = true,
        engine        = 'memtx',
        format        = STORAGE_CONSTANT.FORMAT,
    })

    space:create_index(STORAGE_CONSTANT.INDEX_BY_ID, {
        type          = 'TREE',
        parts         = STORAGE_CONSTANT.INDEX_BY_ID_FIELDS,
        unique        = true,
        if_not_exists = true,
    })

    space:create_index(STORAGE_CONSTANT.INDEX_BY_BUCKET_ID, {
        type          = 'TREE',
        parts         = STORAGE_CONSTANT.INDEX_BY_BUCKET_ID_FIELDS,
        unique        = false,
        if_not_exists = true,
    })
end

local function get_by_id(id)
    local tuple = box.space[STORAGE_CONSTANT.SPACE_NAME]:get({id})
    return tuple and tuple:tomap({ names_only = true })
end

local function update_by_id(id, bucket_id, data)
    local space = box.space[STORAGE_CONSTANT.SPACE_NAME]
    local pos = STORAGE_CONSTANT.POS

    if not space:get({id}) then
        return space
            :insert({
                [pos[STORAGE_CONSTANT.ID]]        = id,
                [pos[STORAGE_CONSTANT.BUCKET_ID]] = bucket_id,
                [pos[STORAGE_CONSTANT.DATA]]      = data,
            })
            :tomap({ names_only = true })
    else
        return space
            :update({id}, {
                {'=', pos[STORAGE_CONSTANT.DATA], data}
            })
            :tomap({ names_only = true })
    end
end

local function delete_by_id(id)
    local tuple = box.space[STORAGE_CONSTANT.SPACE_NAME]:delete({id})
    return tuple and tuple:tomap({ names_only = true })
end

local API_FUNCTIONS = {
    {'get_by_id',    get_by_id},
    {'update_by_id', update_by_id},
    {'delete_by_id', delete_by_id},
}

local function init(opts)
    if opts.is_master then
        init_space()
    end

    for _, v in pairs(API_FUNCTIONS) do
        local name, func = unpack(v)

        if opts.is_master then
            box.schema.func.create(name, { if_not_exists = true })
        end

        rawset(_G, name, func)
    end
end

return {
    role_name = 'app.roles.storage',

    init = init,

    dependencies = {
        'cartridge.roles.vshard-storage'
    },
}
