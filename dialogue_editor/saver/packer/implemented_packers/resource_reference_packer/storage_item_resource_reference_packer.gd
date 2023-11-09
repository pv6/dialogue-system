tool
extends ObjectPacker


const STORAGE_ITEM_FIELD := "storage_item"


# virtual
func get_type_name() -> String:
    return "StorageItemResourceReference"


# virtual
func pack(object: Object):
    var reference := object as StorageItemResourceReference
    assert(reference)

    var output = .pack(reference)

    output[STORAGE_ITEM_FIELD] = _meta_packer.pack(reference.storage_item)

    return output
