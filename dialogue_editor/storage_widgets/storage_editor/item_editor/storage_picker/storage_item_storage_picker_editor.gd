tool
extends StorageItemEditor


signal edit_storage_pressed()

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
        # check that "None" is not selected
        var id = storage_picker.get_selected_item_id()
        if id != -1:
            var storage_item = StorageItem.new()
            storage_item.storage_path = storage.resource_path
            storage_item.storage_id = id
            return storage_item
    return ""


func set_item(item: StorageItem) -> void:
    if storage_picker and storage and item:
        # var ids: PoolIntArray = storage.get_item_ids(item)
        # if not ids.empty():
        #     storage_picker.select(ids[0])
        storage_picker.select(item.storage_id)


func reset_item() -> void:
    if storage_picker:
        storage_picker.select(-1)


func _on_storage_picker_edit_storage_pressed() -> void:
    emit_signal("edit_storage_pressed")
