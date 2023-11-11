tool
extends ObjectPacker


const DATA_FIELD := "data"
const MUST_BE_UNIQUE_FIELD := "must_be_unique"
const LOCKED_IDS_FIELD := "locked_ids"
const HIDDEN_IDS_FIELD := "hidden_ids"


# virtual
func get_type_name() -> String:
    return "Storage"


# virtual
func pack(object: Object):
    var storage := object as Storage
    assert(storage)

    var output = .pack(storage)

    output[DATA_FIELD] = _meta_packer.pack(storage._data)

    output[MUST_BE_UNIQUE_FIELD] = storage.must_be_unique

    output[LOCKED_IDS_FIELD] = _meta_packer.pack_set(storage._locked_ids)
    output[HIDDEN_IDS_FIELD] = _meta_packer.pack_set(storage._hidden_ids)

    return output
