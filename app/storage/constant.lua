require('strict').on()

local STORAGE_CONSTANT = {}

STORAGE_CONSTANT.SPACE_NAME = 'my_storage'

STORAGE_CONSTANT.ID            = 'id'
STORAGE_CONSTANT.BUCKET_ID     = 'bucket_id'
STORAGE_CONSTANT.DATA          = 'data'

STORAGE_CONSTANT.FORMAT = {
    { name = STORAGE_CONSTANT.ID,        type = 'string'   },
    { name = STORAGE_CONSTANT.BUCKET_ID, type = 'unsigned' },
    { name = STORAGE_CONSTANT.DATA,      type = 'any'      },
}

STORAGE_CONSTANT.POS = {}
for i, v in pairs(STORAGE_CONSTANT.FORMAT) do
    STORAGE_CONSTANT.POS[v.name] = i
end

STORAGE_CONSTANT.INDEX_BY_ID = 'by_id'
STORAGE_CONSTANT.INDEX_BY_ID_FIELDS = {
    STORAGE_CONSTANT.ID
}

STORAGE_CONSTANT.INDEX_BY_BUCKET_ID = 'by_bucket_id'
STORAGE_CONSTANT.INDEX_BY_BUCKET_ID_FIELDS = {
    STORAGE_CONSTANT.BUCKET_ID
}

return STORAGE_CONSTANT
