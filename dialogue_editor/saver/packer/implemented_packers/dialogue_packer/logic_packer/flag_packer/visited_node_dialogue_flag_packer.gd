tool
extends "dialogue_flag_packer.gd"


const NODE_ID_FIELD := "node_id"


# virtual
func get_type_name() -> String:
    return "VisitedNodeDialogueFlag"


# virtual
func pack(object: Object):
    var visited_node_flag := object as VisitedNodeDialogueFlag
    assert(visited_node_flag)

    var output = .pack(visited_node_flag)

    output[NODE_ID_FIELD] = visited_node_flag.node_id

    return output
