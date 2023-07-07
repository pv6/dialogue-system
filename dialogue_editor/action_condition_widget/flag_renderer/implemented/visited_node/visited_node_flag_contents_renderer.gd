tool
extends "../../dialogue_flag_contents_renderer.gd"


onready var _node_id_line_edit: LineEdit = $NodeIdLineEdit


# virtual
func _update_values() -> void:
    if not _node_id_line_edit:
        return

    if flag:
        _node_id_line_edit.text = str(flag.node_id)
    else:
        _node_id_line_edit.text = ""


func _on_node_id_line_edit_focus_exited():
    call_deferred("_call_set_visited_node_id", int(_node_id_line_edit.text))


func _call_set_visited_node_id(visited_node_id: int) -> void:
    if not _session.dialogue_undo_redo.commit_action("Set Visited Node Id To %d" % visited_node_id, self, "_set_visited_node_id", {"visited_node_id": visited_node_id}):
        _update_values()


# args = {"visited_node_id"}
func _set_visited_node_id(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var visited_flag := _get_flag(dialogue) as VisitedNodeDialogueFlag
    if not visited_flag:
        return null

    var visited_node_id : int = args["visited_node_id"]
    if not dialogue.nodes.has(visited_node_id):
        return null
    visited_flag.node_id = visited_node_id

    return dialogue


func _on_node_id_line_edit_text_entered(new_text: String) -> void:
    _node_id_line_edit.release_focus()


func _on_node_id_line_edit_focus_entered():
    yield(get_tree(), "idle_frame")
    _node_id_line_edit.select_all()
