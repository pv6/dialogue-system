tool
extends ObjectPacker


const RESOURCE_PATH_FIELD := "path"


# virtual
func get_type_name() -> String:
    return "ExternalResourceReference"


# virtual
func pack(object: Object):
    var reference := object as ExternalResourceReference
    assert(reference)

    var output = .pack(reference)

    output[RESOURCE_PATH_FIELD] = reference.external_path.get_basename()

    return output
