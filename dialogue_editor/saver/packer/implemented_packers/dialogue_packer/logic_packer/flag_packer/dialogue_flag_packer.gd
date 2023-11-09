tool
extends ObjectPacker


const VALUE_FIELD = "value"


# virtual
func get_type_name() -> String:
    return "DialogueFlag"


# virtual
func pack(object: Object):
    var flag := object as DialogueFlag
    assert(flag)

    var output = .pack(flag)

    output[VALUE_FIELD] = flag.value

    return output
