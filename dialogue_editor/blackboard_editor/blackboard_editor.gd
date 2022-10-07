tool
class_name BlackboardEditor
extends AcceptDialog


signal blackboard_edited()

export(Resource) var blackboard setget set_blackboard

onready var _blackboard_picker: BlackboardPicker = $Contents/BlackboardPicker
onready var _storage_edior: StorageEditor = $Contents/StorageEditor


func _ready() -> void:
    self.blackboard = blackboard


func _on_blackboard_selected(new_blackboard: Storage):
#    self.blackboard = new_blackboard
    pass


func set_blackboard(new_blackboard: Storage) -> void:
    blackboard = new_blackboard

    if _blackboard_picker and _storage_edior:
#        # set blackboard picker selection
#        _blackboard_picker.selected_blackboard = new_blackboard

        # set blackboard fields to storage editor
        if new_blackboard:
            _storage_edior.storage = new_blackboard
        else:
            _storage_edior.storage = null


func _on_blackboard_edited():
    if blackboard:
        blackboard = _storage_edior.storage
        ResourceSaver.save(blackboard.resource_path, blackboard)
        emit_signal("blackboard_edited")
