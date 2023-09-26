tool
class_name Storage
extends Clonable


export(bool) var must_be_unique = true

var name: String setget ,get_name

# export data for it to be saved to disk
export(Dictionary) var _data: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _locked_ids: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _hidden_ids: Dictionary
# this is supposed to be a set, but godot doesn't have those
export(Dictionary) var _shown_ids: Dictionary setget _set_shown_ids

var _uid_generator := UIDGenerator.new()


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
    _locked_ids = {}


func add_item(new_item, id := UIDGenerator.DUMMY_ID) -> int:
    if not _is_item_valid(new_item):
        return UIDGenerator.DUMMY_ID

    if id == UIDGenerator.DUMMY_ID:
        id = _uid_generator.generate_id()
    assert(not _data.has(id))

    _set_item(id, new_item)
    emit_changed()
    return id


func set_item(id: int, new_item) -> bool:
    assert(_data.has(id))
    if not _is_item_valid(new_item):
        return false
    _set_item(id, new_item)
    emit_changed()
    return true


func remove_item(id: int) -> void:
    _remove_item(id)
    emit_changed()


func remove_items(ids: Array) -> void:
    for id in ids:
        _remove_item(id)
    emit_changed()


func get_item(id: int):
    if not _data.has(id):
        return null
    return _data[id]


func find_item(item) -> int:
    for id in _data.keys():
        if item == _data[id]:
            return id
    return UIDGenerator.DUMMY_ID


func has_id(id: int) -> bool:
    return _data.has(id)


func has_item(item) -> bool:
    return _data.values().has(item)


func lock_item(id: int) -> void:
    _locked_ids[id] = true
    emit_changed()


func unlock_item(id: int) -> void:
    _locked_ids.erase(id)
    emit_changed()


func hide_item(id: int) -> void:
    _hidden_ids[id] = true
    _shown_ids.erase(id)
    emit_changed()


func show_item(id: int) -> void:
    _hidden_ids.erase(id)
    _shown_ids[id] = true
    emit_changed()


func is_locked(id: int) -> bool:
    return _locked_ids.has(id)


func is_hidden(id: int) -> bool:
    return _hidden_ids.has(id)


func is_all_hidden() -> bool:
    for id in ids():
        if not is_hidden(id):
            return false
    return true


func get_item_ids(reference_item) -> Array:
    var output = []
    for id in ids():
        if _data[id] == reference_item:
            output.append(id)
    return output


func ids() -> Array:
    return _data.keys()


func shown_ids() -> Array:
    return _shown_ids.keys()


func _set_shown_ids(new_shown_ids: Dictionary) -> void:
    _shown_ids = new_shown_ids

    if _shown_ids.size() != _data.size() - _hidden_ids.size():
        _shown_ids = _data.duplicate()
        for hidden_id in _hidden_ids.keys():
            _shown_ids.erase(hidden_id)


func items() -> Array:
    return _data.values()


func clone() -> Clonable:
    var copy := .clone()

    for id in _data.keys():
        copy._set_item(id, _data[id])

    copy._locked_ids = _locked_ids.duplicate()

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


func _remove_item(id: int) -> void:
    assert(_data.has(id))
    _set_item(id, null)  # disconnect from 'changed' signal of item
    _data.erase(id)
