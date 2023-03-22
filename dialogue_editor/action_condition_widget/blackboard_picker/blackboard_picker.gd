tool
class_name BlackboardPicker
extends DisableableControl


signal blackboard_selected(blackboard_reference)
signal blackboard_forced_selected(blackboard_reference)

var selected_blackboard: StorageItem setget set_selected_blackboard, get_selected_blackboard

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _open_blackboard_dialog: FileDialog = $Dialogs/OpenBlackboardDialog
onready var _storage_picker: StoragePicker = $StoragePicker
onready var _open_button: IconButton = $OpenButton


func _ready() -> void:
    if not _session.is_connected("changed", self, "_on_session_changed"):
        _session.connect("changed", self, "_on_session_changed")
    _on_session_changed()


func set_selected_blackboard(new_selected_blackboard: StorageItem) -> void:
    if new_selected_blackboard:
        _storage_picker.select(new_selected_blackboard.storage_id)
    else:
        _storage_picker.select(-1)


func get_selected_blackboard() -> StorageItem:
    if not _storage_picker or not _storage_picker.storage:
        return null
    return _storage_picker.storage.get_item_reference(_storage_picker.selected_item_id)


func _on_session_changed() -> void:
    if _session.dialogue:
        _storage_picker.storage = _session.dialogue.blackboards
    else:
        _storage_picker.storage = null


func _on_open_blackboard_pressed() -> void:
    _open_blackboard_dialog.popup_centered()


func _on_files_selected(paths):
    var blackboards_to_add := []
    for path in paths:
        var new_blackboard = load(path) as Storage
        if new_blackboard:
            blackboards_to_add.push_back(new_blackboard)
    var names = ""
    for blackboard in blackboards_to_add:
        names += " \"" + blackboard.name + "\""
    _session.dialogue_undo_redo.commit_action("Add Blackboards" + names, self, "_add_blackboards", {"blackboards": blackboards_to_add})


func _add_blackboards(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var blackboards_to_add: Array = args["blackboards"]
    if blackboards_to_add.size() == 0:
        return null

    var indices := []

    for blackboard in blackboards_to_add:
        var index = dialogue.add_blackboard(blackboard)
        if index != -1:
            indices.push_back(index)

    # TODO: select first added blackboard
#    _storage_picker.select(indices[0])
#    emit_signal("blackboard_selected", blackboards)

    return dialogue


func _get_blackboard_resource_reference(id: int) -> ResourceReference:
    return StorageItemResourceReference.new(_storage_picker.storage.get_item_reference(id))


func _on_storage_picker_item_selected(id: int):
    emit_signal("blackboard_selected", _get_blackboard_resource_reference(id))


func _on_storage_picker_item_forced_selected(id):
    emit_signal("blackboard_forced_selected", _get_blackboard_resource_reference(id))


func _on_edit_storage_pressed():
     _session.dialogue_editor.open_dialogue_blackboards_editor()
