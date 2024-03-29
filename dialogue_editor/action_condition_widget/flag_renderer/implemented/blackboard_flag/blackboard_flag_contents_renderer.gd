tool
extends "../../dialogue_flag_contents_renderer.gd"


onready var _blackboard_picker: BlackboardPicker = $BlackboardPicker
onready var _flag_storage_picker: StoragePicker = $FlagContainer/FlagStoragePicker


# takes storage item that points to blackboard within dialogue.blackboards
func _set_blackboard(blackboard: StorageItem) -> void:
    if not _flag_storage_picker or not flag or not _blackboard_picker:
        return

    # re-grab blackboard reference in case force selection occured
    _blackboard_picker.selected_blackboard = blackboard
    blackboard = _blackboard_picker.selected_blackboard

    _flag_storage_picker.storage = blackboard.get_value().get_resource()


func _update_values() -> void:
    if not _flag_storage_picker:
        return

    if flag:
        var item: StorageItem
        if flag.blackboard and flag.blackboard is StorageItemResourceReference:
            item = flag.blackboard.storage_item
        _set_blackboard(item)
        _flag_storage_picker.select(flag.field_id)
    else:
        _set_blackboard(null)


func _on_blackboard_selected(blackboard_reference: ResourceReference) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Blackboard", self, "_set_flag_blackboard", {"blackboard_reference": blackboard_reference})


func _on_blackboard_forced_selected(blackboard_reference: ResourceReference) -> void:
    flag.blackboard = blackboard_reference


func _on_edit_storage_pressed() -> void:
    _session.dialogue_editor.open_blackboard_editor(_blackboard_picker.selected_blackboard)


func _on_flag_storage_picker_item_selected(id):
    _session.dialogue_undo_redo.commit_action("Set Flag", self, "_set_flag_id", {"id": id})


func _on_flag_storage_picker_item_forced_selected(id):
    if flag and flag.field_id != id:
        flag.field_id = id


func _set_flag_blackboard(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null

    _get_flag(dialogue).blackboard = args["blackboard_reference"]
    return dialogue


func _set_flag_id(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null

    _get_flag(dialogue).field_id = args["id"]
    return dialogue
