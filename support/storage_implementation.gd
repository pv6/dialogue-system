tool
class_name StorageImplementation
extends Resource


# Storage
export(Resource) var template: Resource setget set_template

export(Dictionary) var _id_to_value: Dictionary

var default_value = null

# Dictionary[String, int]
var _name_to_id: Dictionary


func _init(template: Storage = null, default_value = Reference.new()) -> void:
    self.default_value = default_value
    set_template(template)


func s(item, value) -> void:
    var name = str(item)
    set_by_id(_name_to_id[name], value)


func set_by_id(id: int, value) -> void:
    _id_to_value[id] = value


func g(item):
    var name = str(item)
    return get_by_id(_name_to_id[name])


func get_by_id(id: int):
    return _id_to_value[id]


func has(item) -> bool:
    var name := str(item)
    return name in _name_to_id and _id_to_value.has(_name_to_id[name])


func clear(value = default_value) -> void:
    for id in _id_to_value.keys():
        _id_to_value[id] = value


func set_template(new_template: Storage) -> void:
    template = new_template
    if template:
        for id in template.ids():
            var item = template.get_item(id)
            _name_to_id[str(item)] = id
            if not _id_to_value.has(id):
                _id_to_value[id] = default_value
    property_list_changed_notify()


func is_valid(template: Storage) -> bool:
    for item in template.items():
        if not has(item):
            return false
    return true
