tool
class_name BlackboardEditor
extends AcceptDialog


export(Resource) var blackboard setget set_blackboard

onready var _blackboard_picker: BlackboardPicker = $Contents/BlackboardPicker
onready var _storage_edior: StorageEditor = $Contents/StorageEditor


func _ready() -> void:
    self.blackboard = blackboard


func _on_blackboard_selected(new_blackboard: Blackboard):
    self.blackboard = new_blackboard


func set_blackboard(new_blackboard: Blackboard) -> void:
    blackboard = new_blackboard

    if _blackboard_picker and _storage_edior:
        # set blackboard picker selection
        _blackboard_picker.selected_blackboard = new_blackboard

        # set blackboard fields to storage editor
        if new_blackboard:
            _storage_edior.storage = new_blackboard.field_names
        else:
            _storage_edior.storage = null


func _on_blackboard_edited():
    if blackboard:
        blackboard.field_names = _storage_edior.storage
        ResourceSaver.save(blackboard.resource_path, blackboard)
