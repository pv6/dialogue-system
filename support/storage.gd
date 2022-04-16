tool
class_name Storage
extends Resource


export(int) var max_id = 0
export(bool) var must_be_unique = true

# export data for it to be saved to disk
export(Dictionary) var _data: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _locked_indices: Dictionary


func _init() -> void:
    _data = {}
    _locked_indices = {}


func add_item(new_item) -> int:
    if not _is_item_valid(new_item):
        return -1

    _data[max_id] = new_item
    max_id += 1
    emit_changed()
    return max_id - 1


func set_item(id: int, new_item) -> bool:
    assert(_data.has(id))
    if not _is_item_valid(new_item):
        return false
    _data[id] = new_item
    emit_changed()
    return true


func remove_item(id: int) -> void:
    assert(_data.has(id))
    _data.erase(id)
    emit_changed()


func get_item(id: int):
    if id == -1 or not _data.has(id):
        return null
    return _data[id]


func has_id(id: int) -> bool:
    return _data.has(id)


func has_item(item) -> bool:
    return _data.values().has(item)


func lock_item(id: int) -> void:
    _locked_indices[id] = true


func unlock_item(id: int) -> void:
    _locked_indices.erase(id)


func is_locked(id: int) -> bool:
    return _locked_indices.has(id)


func get_item_ids(reference_item) -> PoolIntArray:
    var output = PoolIntArray()
    for id in ids():
        if _data[id] == reference_item:
            output.append(id)
    return output


func ids() -> Array:
    return _data.keys()


func items() -> Array:
    return _data.values()


func clone() -> Storage:
    var copy := get_script().new() as Storage
    copy._data = _data.duplicate()
    copy._locked_indices = _locked_indices.duplicate()
    copy.max_id = max_id
    
    var path = resource_path
    resource_path = ""
    copy.resource_path = path

    return copy

func _is_item_valid(item) -> bool:
    if not must_be_unique:
        return true

    if not item or str(item) == "":
        return false

    if item is StorageItem:
        for existing_item in items():
            if existing_item.storage_id == item.storage_id:
                return false
        return true

    return not has_item(item)
