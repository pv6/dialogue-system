tool
class_name VisitedNodeDialogueFlag
extends DialogueFlag


export(int) var node_id := -1 setget set_node_id


func set_node_id(new_node_id: int) -> void:
    if node_id == new_node_id:
        return
    node_id = new_node_id
    emit_changed()


# virtual
func check(input: DialogueNodeLogicInput) -> bool:
    return input.blackboards.g("local").g("auto_visited_node_%d" % node_id) == value
