tool
extends ResourceReference
class_name StorageItemResourceReference


# StorageItem
export(Resource) var storage_item: Resource setget set_storage_item


func _init(storage_item: StorageItem = null) -> void:
    self.storage_item = storage_item


func set_resource(new_resource: Resource) -> void:
    storage_item.set_value(new_resource)
    emit_changed()


func clone() -> ResourceReference:
    var copy = .clone()
    copy.storage_item = storage_item.clone()
    return copy


func set_storage_item(new_storage_item: StorageItem) -> void:
    if storage_item:
        storage_item.disconnect("changed", self, "emit_changed")
    storage_item = new_storage_item
    if storage_item:
        storage_item.connect("changed", self, "emit_changed")
    emit_changed()


func _get_resource() -> Resource:
    if storage_item:
        return storage_item.get_value()
    return null
