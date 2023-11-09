tool
extends "dialogue_flag_packer.gd"


const BLACKBOARD_ITEM_FIELD := "blackboard_item"


# virtual
func get_type_name() -> String:
    return "BlackboardDialogueFlag"


# virtual
func pack(object: Object):
    var blackboard_flag := object as BlackboardDialogueFlag
    assert(blackboard_flag)

    var output = .pack(blackboard_flag)

    output[BLACKBOARD_ITEM_FIELD] = _meta_packer.pack(blackboard_flag.blackboard_field)

    return output
