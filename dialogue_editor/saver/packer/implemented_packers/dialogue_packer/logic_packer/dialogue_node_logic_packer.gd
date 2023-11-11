tool
extends ObjectPacker


const FLAGS_FIELD := "flags"
const AUTO_FLAGS_FIELD := "auto_flags"
const USE_FLAGS_FIELD := "use_flags"
const SCRIPT_FIELD := "script"
const USE_SCRIPT_FIELD := "use_script"


# virtual
func get_type_name() -> String:
    return "DialogueNodeLogic"


# virtual
func pack(object: Object):
    var logic := object as DialogueNodeLogic
    assert(logic)

    var output = .pack(logic)

    var packed_flags = []
    for flag in logic.flags:
        packed_flags.push_back(_meta_packer.pack(flag))
    output[FLAGS_FIELD] = packed_flags

    var packed_auto_flags = []
    for flag in logic.auto_flags:
        packed_auto_flags.push_back(_meta_packer.pack(flag))
    output[AUTO_FLAGS_FIELD] = packed_auto_flags

    output[USE_FLAGS_FIELD] = logic.use_flags

    output[SCRIPT_FIELD] = logic.node_script
    output[USE_SCRIPT_FIELD] = logic.use_script

    return output
