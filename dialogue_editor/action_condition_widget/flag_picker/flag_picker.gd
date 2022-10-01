tool
class_name FlagPicker
extends Control


const VALUES := [true, false]

export(int) var node_id: int setget set_node_id
export(String, "condition", "action") var property: String
export(int) var flag_index
export(Resource) var flag setget set_flag
export(bool) var disabled := false setget set_disabled

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _blackboard_picker: BlackboardPicker = $BlackboardPicker
onready var _flag_storage_picker: StoragePicker = $FlagContainer/FlagStoragePicker
onready var _value_option_button: OptionButton = $ValueContainer/ValueOptionButton


func set_flag(new_flag: DialogueFlag) -> void:
    if flag:
        flag.disconnect("changed", self, "_on_flag_changed")
    flag = new_flag
    if flag:
        flag.connect("changed", self, "_on_flag_changed")
    _update_values()


func set_node_id(new_node_id: int) -> void:
    node_id = new_node_id


func set_disabled(value: bool) -> void:
    disabled = value
    _blackboard_picker.disabled = value
    _flag_storage_picker.disabled = value
    _value_option_button.disabled = value


func _set_blackboard(blackboard: Blackboard) -> void:
    if not _flag_storage_picker or not flag or not _blackboard_picker:
        return

    # re-grab blackboard reference in case force selection occured
    _blackboard_picker.selected_blackboard = blackboard
    blackboard = _blackboard_picker.selected_blackboard

    if blackboard:
        _flag_storage_picker.storage = blackboard.field_names
    else:
        _flag_storage_picker.storage = null


func _update_values() -> void:
    if flag:
        # remember id, because setting blackboard resets id to -1
        var id = flag.id
        _set_blackboard(flag.blackboard)
        _flag_storage_picker.select(id)
        _value_option_button.select(0 if flag.value else 1)
    else:
        _set_blackboard(null)
        _value_option_button.select(0)


func _on_blackboard_selected(blackboard: Blackboard) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Blackboard", self, "_set_flag_blackboard", {"blackboard": blackboard})


func _on_blackboard_forced_selected(blackboard: Blackboard) -> void:
    flag.blackboard = blackboard


func _on_flag_value_selected(value_index: int) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Value", self, "_set_flag_value", {"value": VALUES[value_index]})


func _on_edit_storage_pressed() -> void:
    _session.dialogue_editor.open_blackboard_editor(_blackboard_picker.selected_blackboard)


func _on_flag_storage_picker_item_selected(id):
    _session.dialogue_undo_redo.commit_action("Set Flag", self, "_set_flag_id", {"id": id})


func _on_flag_changed() -> void:
    _update_values()


func _on_flag_storage_picker_item_forced_selected(id):
    if flag and flag.id != id:
        flag.id = id


func _set_flag_blackboard(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].blackboard = args["blackboard"]
    return dialogue


func _set_flag_id(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].id = args["id"]
    return dialogue


func _set_flag_value(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].value = args["value"]
    return dialogue
