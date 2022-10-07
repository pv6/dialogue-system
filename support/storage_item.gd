tool
class_name StorageItem
extends Resource


# ResourceReference
export(Resource) var storage_reference: Resource
export(int) var storage_id := -1 setget set_storage_id


func _init(storage_reference: ResourceReference = null, storage_id := -1) -> void:
    self.storage_reference = storage_reference
    self.storage_id = storage_id


func _to_string() -> String:
    return str(get_value())


func set_storage_id(new_storage_id: int) -> void:
    # TODO: check if id is valid?
    if new_storage_id != storage_id:
        storage_id = new_storage_id
        emit_changed()


func get_value():
    # load storage resource from path
    var storage = storage_reference.get_resource()

    if not storage:
        return null

    # get value
    var value = storage.get_item(storage_id)
    if not value:
        return null

    return value


func equals(other: StorageItem) -> bool:
    return storage_reference.equals(other.storage_reference) and storage_id == other.storage_id


func clone() -> StorageItem:
    var copy: StorageItem = duplicate()
    
    copy.storage_reference = storage_reference.clone()
    
    return copy
