tool
class_name BlackboardEditor
extends AcceptDialog


# StorageItem
export(Resource) var blackboard setget set_blackboard

onready var _blackboard_picker: BlackboardPicker = $Contents/BlackboardPicker
onready var _storage_edior: StorageEditor = $Contents/StorageEditor


func _ready() -> void:
    self.blackboard = blackboard


func _on_blackboard_selected(new_blackboard_reference: StorageItemResourceReference):
    self.blackboard = new_blackboard_reference.storage_item


func set_blackboard(new_blackboard: StorageItem) -> void:
    blackboard = new_blackboard

    if _blackboard_picker and _storage_edior:
        # set blackboard picker selection
        _blackboard_picker.selected_blackboard = new_blackboard

        # set blackboard fields to storage editor
        if new_blackboard:
            _storage_edior.storage = new_blackboard.get_value().get_resource()
        else:
            _storage_edior.storage = null


func _on_blackboard_edited():
    if blackboard and _storage_edior.storage:
        var reference: ResourceReference = blackboard.get_value()
        if reference:
            reference.set_resource(_storage_edior.storage)
