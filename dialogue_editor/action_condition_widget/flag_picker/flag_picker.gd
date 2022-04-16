tool
class_name FlagPicker
extends Control


const VALUES := [true, false]

export(int) var node_id: int
export(String, "condition", "action") var property: String
export(int) var flag_index
export(Resource) var flag setget set_flag
export(bool) var disabled := false setget set_disabled

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")
var _new_blackboard: Blackboard
var _new_id: int
var _new_value: bool

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
    _new_blackboard = blackboard
    _session.dialogue_undo_redo.commit_action("Set Flag Blackboard", self, "_set_flag_blackboard")


func _on_blackboard_forced_selected(blackboard: Blackboard) -> void:
    flag.blackboard = blackboard


func _on_flag_value_selected(value_index: int) -> void:
    _new_value = VALUES[value_index]
    _session.dialogue_undo_redo.commit_action("Set Flag Value", self, "_set_flag_value")


func _on_edit_storage_pressed() -> void:
    _session.dialogue_editor.open_blackboard_editor(_blackboard_picker.selected_blackboard)


func _on_flag_storage_picker_item_selected(id):
    _new_id = id
    _session.dialogue_undo_redo.commit_action("Set Flag", self, "_set_flag_id")


func _on_flag_changed() -> void:
    _update_values()


func _on_flag_storage_picker_item_forced_selected(id):
    if flag and flag.id != id:
        flag.id = id


func _set_flag_blackboard(dialogue: Dialogue) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].blackboard = _new_blackboard
    return dialogue


func _set_flag_id(dialogue: Dialogue) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].id = _new_id
    return dialogue


func _set_flag_value(dialogue: Dialogue) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].value = _new_value
    return dialogue
