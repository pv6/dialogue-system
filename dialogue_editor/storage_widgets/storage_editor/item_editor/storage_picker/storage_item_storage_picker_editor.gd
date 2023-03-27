tool
extends StorageItemEditor


signal edit_storage_pressed()
signal item_selected(item)
signal item_forced_selected(item)

export(Resource) var storage: Resource setget set_storage

onready var storage_picker: StoragePicker = $StoragePicker


func _ready() -> void:
    self.storage = storage


func set_storage(new_storage: Storage) -> void:
    storage = new_storage
    if storage_picker:
        storage_picker.storage = storage


func get_item():
    if storage_picker and storage:
        var id = storage_picker.get_selected_item_id()
        return _id_to_storage_item(id)
    return ""


func set_item(item: StorageItem) -> void:
    if storage_picker:
        if item:
            storage_picker.select(item.storage_id)
        else:
            storage_picker.select(-1)


func select(item: StorageItem) -> void:
    set_item(item)


func reset_item() -> void:
    if storage_picker:
        storage_picker.select(-1)


func _on_storage_picker_edit_storage_pressed() -> void:
    emit_signal("edit_storage_pressed")


func _id_to_storage_item(id: int) -> StorageItem:
    if storage_picker and storage_picker.storage:
        return storage_picker.storage.get_item_reference(id)
    return null


func _on_storage_picker_item_selected(id: int) -> void:
    emit_signal("item_selected", _id_to_storage_item(id))


func _on_storage_picker_item_forced_selected(id: int) -> void:
    emit_signal("item_forced_selected", _id_to_storage_item(id))
