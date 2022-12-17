tool
class_name Storage
extends Clonable


export(int) var max_id = 0
export(bool) var must_be_unique = true

var name: String setget ,get_name

# export data for it to be saved to disk
export(Dictionary) var _data: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _locked_indices: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _hidden_indices: Dictionary


func _to_string() -> String:
    return get_name()


func get_name() -> String:
    # I AM SORRY OK
    # NAME NEEDS TO UPDATE IF FILE NAME CHANGES, HENCE GETTER
    var ext = "." + resource_path.get_extension()
    var filename := resource_path.get_file().trim_suffix("." + resource_path.get_extension())
    if filename != "" and not ":" in ext:
        return filename
    # BUT CUSTOMIZABLE EXPORTED NAME GETS BUGGED TO HELL
    # SO IT'S THIS OR NOTHING BABY IT'S THIS OR NOTHING
    return "local"


func _init() -> void:
    _data = {}
    _locked_indices = {}


func add_item(new_item) -> int:
    if not _is_item_valid(new_item):
        return -1

    _set_item(max_id, new_item)
    max_id += 1
    emit_changed()
    return max_id - 1


func set_item(id: int, new_item) -> bool:
    assert(_data.has(id))
    if not _is_item_valid(new_item):
        return false
    _set_item(id, new_item)
    emit_changed()
    return true


func remove_item(id: int) -> void:
    assert(_data.has(id))
    _set_item(id, null)  # disconnect from 'changed' signal of item
    _data.erase(id)
    emit_changed()


func get_item(id: int):
    if id == -1 or not _data.has(id):
        return null
    return _data[id]


func find_item(item) -> int:
    for id in _data.keys():
        if item == _data[id]:
            return id
    return -1


func has_id(id: int) -> bool:
    return _data.has(id)


func has_item(item) -> bool:
    return _data.values().has(item)


func lock_item(id: int) -> void:
    _locked_indices[id] = true
    emit_changed()


func unlock_item(id: int) -> void:
    _locked_indices.erase(id)
    emit_changed()


func hide_item(id: int) -> void:
    _hidden_indices[id] = true
    emit_changed()


func show_item(id: int) -> void:
    _hidden_indices.erase(id)
    emit_changed()


func is_locked(id: int) -> bool:
    return _locked_indices.has(id)


func is_hidden(id: int) -> bool:
    return _hidden_indices.has(id)


func is_all_hidden() -> bool:
    for id in ids():
        if not is_hidden(id):
            return false
    return true


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


func clone() -> Clonable:
    var copy := .clone()

    for id in _data.keys():
        copy._set_item(id, _data[id])

    copy._locked_indices = _locked_indices.duplicate()

    return copy


func get_storage_reference() -> ResourceReference:
    var output: ResourceReference

    if resource_path.get_extension().is_valid_filename():
        output = ExternalResourceReference.new()
        output.external_path = resource_path
    else:
        output = DirectResourceReference.new()
        output.direct_reference = self

    return output


func get_item_reference(id: int) -> StorageItem:
    var output = StorageItem.new()
    output.storage_reference = get_storage_reference()
    output.storage_id = id
    return output


func _is_item_valid(item) -> bool:
    if not item or str(item) == "":
        return false

    if not must_be_unique:
        return true

    if item is Object and item.has_method("equals"):
        for existing_item in items():
            if item.equals(existing_item):
                return false
        return true

    return not has_item(item)


func _set_item(id: int, new_item) -> void:
    if _data.has(id) and _data[id] is Resource and _data[id].is_connected("changed", self, "emit_changed"):
        _data[id].disconnect("changed", self, "emit_changed")
    _data[id] = new_item
    if new_item is Resource:
        new_item.connect("changed", self, "emit_changed")
