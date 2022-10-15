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


func _ready():
    _update_values()
    

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
    if _blackboard_picker:
        _blackboard_picker.disabled = value
    if _flag_storage_picker:
        _flag_storage_picker.disabled = value
    if _value_option_button:
        _value_option_button.disabled = value


# takes storage item that points to blackboard within dialogue.blackboards
func _set_blackboard(blackboard: StorageItem) -> void:
    if not _flag_storage_picker or not flag or not _blackboard_picker:
        return

    # re-grab blackboard reference in case force selection occured
    _blackboard_picker.selected_blackboard = blackboard
    blackboard = _blackboard_picker.selected_blackboard

    _flag_storage_picker.storage = blackboard.get_value().get_resource()


func _update_values() -> void:
    if not _flag_storage_picker or not _value_option_button:
        return
    
    if flag:
        var item: StorageItem
        if flag.blackboard and flag.blackboard is StorageItemResourceReference:
            item = flag.blackboard.storage_item
        _set_blackboard(item)
        _flag_storage_picker.select(flag.field_id)
        _value_option_button.select(0 if flag.value else 1)
    else:
        _set_blackboard(null)
        _value_option_button.select(0)


func _on_blackboard_selected(blackboard_reference: ResourceReference) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Blackboard", self, "_set_flag_blackboard", {"blackboard_reference": blackboard_reference})


func _on_blackboard_forced_selected(blackboard_reference: ResourceReference) -> void:
    flag.blackboard = blackboard_reference


func _on_flag_value_selected(value_index: int) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Value", self, "_set_flag_value", {"value": VALUES[value_index]})


func _on_edit_storage_pressed() -> void:
    _session.dialogue_editor.open_blackboard_editor(_blackboard_picker.selected_blackboard)


func _on_flag_storage_picker_item_selected(id):
    _session.dialogue_undo_redo.commit_action("Set Flag", self, "_set_flag_id", {"id": id})


func _on_flag_changed() -> void:
    _update_values()


func _on_flag_storage_picker_item_forced_selected(id):
    if flag and flag.field_id != id:
        flag.field_id = id


func _set_flag_blackboard(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null
    
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].blackboard = args["blackboard_reference"]
    return dialogue


func _set_flag_id(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null
    
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].field_id = args["id"]
    return dialogue


func _set_flag_value(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null
    
    dialogue.nodes[node_id].get(property + "_logic").flags[flag_index].value = args["value"]
    return dialogue
