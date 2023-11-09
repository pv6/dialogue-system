tool
class_name ObjectPacker
extends Packer


const TYPE_FIELD := "__type"

var _meta_packer := MetaPacker.new()


# virtual
func get_type_name() -> String:
    return "NONE"


# virtual
func pack(object: Object):
    var output = {}

    output[TYPE_FIELD] = get_type_name()

    return output
