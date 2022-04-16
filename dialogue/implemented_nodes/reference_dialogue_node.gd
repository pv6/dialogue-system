tool
class_name ReferenceDialogueNode
extends DialogueNode


enum JumpTo {
    START_OF_NODE,
    END_OF_NODE,
}

export(JumpTo) var jump_to: int = JumpTo.START_OF_NODE setget set_jump_to
export(int) var referenced_node_id: int setget set_referenced_node_id


func get_name() -> String:
    return "Referenced Node " + str(referenced_node_id)


func set_referenced_node_id(new_referenced_node_id: int) -> void:
    if referenced_node_id == new_referenced_node_id:
        return

    referenced_node_id = new_referenced_node_id
    emit_signal("contents_changed")


func set_jump_to(new_jump_to: int) -> void:
    if jump_to == new_jump_to:
        return
    jump_to = new_jump_to
    emit_signal("contents_changed")
