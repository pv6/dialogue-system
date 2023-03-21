tool
extends "../../flag_widget.gd"


const VALUES := [true, false]


onready var _node_id_label: Label = $NodeIdLabel
onready var _node_id_line_edit: LineEdit = $NodeIdLineEdit
onready var _is_visited_option_button: OptionButton = $IsVisitedOptionButton


func _on_disabled_changed() -> void:
    _node_id_label.modulate.v = 0.5 if disabled else 1.0
    _node_id_line_edit.editable = not disabled
    _is_visited_option_button.disabled = disabled


func _update_values() -> void:
    if not _node_id_line_edit or not _is_visited_option_button:
        return

    if flag:
        _node_id_line_edit.text = flag.name.split("_")[-1]
        _is_visited_option_button.select(0 if flag.value else 1)
    else:
        _node_id_line_edit.text = ""
        _is_visited_option_button.select(0)


func _on_is_visited_option_button_item_selected(index: int):
    _session.dialogue_undo_redo.commit_action("Set Visited Node Value", self, "_set_is_visited_value", {"value": VALUES[index]})


func _on_node_id_line_edit_focus_exited():
    call_deferred("_call_set_visited_node_id", int(_node_id_line_edit.text))


func _call_set_visited_node_id(visited_node_id: int) -> void:
    if not _session.dialogue_undo_redo.commit_action("Set Visited Node Id To %d" % visited_node_id, self, "_set_visited_node_id", {"visited_node_id": visited_node_id}):
        _update_values()


# args = {"value"}
func _set_is_visited_value(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    _get_flag(dialogue).value = args["value"]
    return dialogue


# args = {"visited_node_id"}
func _set_visited_node_id(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var visited_node_id: int = args["visited_node_id"]
    if not dialogue.nodes.has(visited_node_id):
        return null

    var edited_flag = _get_flag(dialogue)
    edited_flag.blackboard = dialogue.get_local_blackboard_ref()
    edited_flag.name = "auto_visited_node_%d" % visited_node_id

    return dialogue


func _on_node_id_line_edit_text_entered(new_text: String) -> void:
    _node_id_line_edit.release_focus()


func _on_node_id_line_edit_focus_entered():
    yield(get_tree(), "idle_frame")
    _node_id_line_edit.select_all()
