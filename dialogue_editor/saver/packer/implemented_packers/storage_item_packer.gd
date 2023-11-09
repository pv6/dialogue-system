tool
extends ObjectPacker


const STORAGE_ID_FIELD := "storage_id"
const STORAGE_REFERENCE_FIELD := "storage_reference"


# virtual
func get_type_name() -> String:
    return "StorageItem"


# virtual
func pack(object: Object):
    var storage_item := object as StorageItem
    assert(storage_item)

    var output = .pack(storage_item)

    output[STORAGE_ID_FIELD] = _meta_packer.pack(storage_item.storage_id)
    output[STORAGE_REFERENCE_FIELD] = _meta_packer.pack(storage_item.storage_reference)

    return output
