tool
class_name StorageItem
extends Clonable


# ResourceReference
export(Resource) var storage_reference: Resource setget set_storage_reference
export(int) var storage_id := -1 setget set_storage_id

var value setget set_value, get_value


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
    if not storage():
        return null
    return storage().get_item(storage_id)


func set_value(new_value) -> bool:
    if not storage():
        return false
    return storage().set_item(storage_id, new_value)


func equals(other: StorageItem) -> bool:
    return storage_reference.equals(other.storage_reference) and storage_id == other.storage_id


func clone() -> Clonable:
    var copy: StorageItem = duplicate()
    copy.storage_reference = storage_reference.clone()
    return copy


func storage() -> Resource:
    if storage_reference:
        return storage_reference.resource
    return null


func set_storage_reference(new_storage_reference: ResourceReference) -> void:
    if storage_reference:
        storage_reference.disconnect("changed", self, "emit_changed")
    storage_reference = new_storage_reference
    if storage_reference:
        storage_reference.connect("changed", self, "emit_changed")
    emit_changed()
