tool
class_name StorageItem
extends Resource


const DELETED_VALUE = "DELETED"

export(String) var storage_path: String
export(int) var storage_id := -1

# var value setget ,get_value


func _to_string() -> String:
    return str(get_value())


func get_value():
    # load storage resource from path
    var storage = ResourceLoader.load(storage_path)

    if not storage:
        return DELETED_VALUE

    # get value
    var value = storage.get_item(storage_id)
    if not value:
        return DELETED_VALUE

    return value
