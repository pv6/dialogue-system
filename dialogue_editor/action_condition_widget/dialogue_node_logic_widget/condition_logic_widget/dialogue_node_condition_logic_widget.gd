tool
extends "res://addons/dialogue_system/dialogue_editor/action_condition_widget/dialogue_node_logic_widget/dialogue_node_logic_widget.gd"


onready var _can_only_visit_once_checkbox: CheckBox = $CanOnlyVisitOnceContainer/CheckBox


func set_disabled(new_disabled: bool) -> void:
    .set_disabled(new_disabled)
    if _can_only_visit_once_checkbox:
        _can_only_visit_once_checkbox.disabled = new_disabled


func _on_can_only_visit_once_check_box_toggled(button_pressed: bool) -> void:
    # don't commit if don't have a node attached (see apology in parent class)
    if not logic:
        return
    var name = "Set Node %d Can Only Visit Once To '%s'" % [node_id, button_pressed]
    _session.dialogue_undo_redo.commit_action(name, self, "_set_can_only_visit_once", {"value": button_pressed})


func _update_values() -> void:
    ._update_values()

    if _can_only_visit_once_checkbox:
        if not logic:
            _can_only_visit_once_checkbox.pressed = false
        else:
            _can_only_visit_once_checkbox.pressed = _find_only_visit_once_flag(logic.auto_flags) != -1


func _find_only_visit_once_flag(auto_flags: Array) -> int:
    var flag_name = "auto_visited_node_%d" % node_id
    var pos := -1
    for i in range(auto_flags.size()):
        if auto_flags[i].name == flag_name:
            pos = i
            break
    return pos


# args = {value: bool}
func _set_can_only_visit_once(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    # find flag
    var auto_flags: Array = dialogue.nodes[node_id].condition_logic.auto_flags
    var flag_name = "auto_visited_node_%d" % node_id
    var pos := -1
    for i in range(auto_flags.size()):
        if auto_flags[i].name == flag_name:
            pos = i
            break

    if args["value"]:
        if pos != -1:
            return null
        var can_visit_once_flag := DialogueFlag.new()
        can_visit_once_flag.blackboard = dialogue.get_local_blackboard_ref()
        can_visit_once_flag.name = flag_name
        can_visit_once_flag.value = false
        auto_flags.push_back(can_visit_once_flag)
    else:
        if pos == -1:
            return null
        auto_flags.remove(pos)

    return dialogue
