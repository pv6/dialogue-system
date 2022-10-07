extends ResourceReference
class_name StorageItemResourceReference


# StorageItem
export(Resource) var storage_item


func _init(storage_item: StorageItem = null) -> void:
    self.storage_item = storage_item


func get_resource() -> Resource:
    if storage_item:
        return storage_item.get_value()
    return null


func clone() -> ResourceReference:
    var copy = .clone()
    
    copy.storage_item = storage_item.clone()
    
    return copy
