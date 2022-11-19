tool
class_name StorageImplementation
extends Resource


# Storage
export(Resource) var template: Resource setget set_template
export(Dictionary) var data: Dictionary

var default_value = null


func _init(template: Storage = null, default_value = Reference.new()) -> void:
    self.default_value = default_value
    self.template = template


func s(item, value) -> void:
    var name = str(item)
    assert(data.has(name))
    data[name] = value


func g(item):
    var name = str(item)
    assert(data.has(name))
    return data[name]
    
    
func has(item) -> bool:
    return str(item) in data


func clear(value = default_value) -> void:
    for key in data.keys():
        data[key] = value


func set_template(new_template: Storage) -> void:
    template = new_template
    if template:
        for item in template.items():
            if not has(item):
                data[str(item)] = default_value
    property_list_changed_notify()
            
            
func is_valid(template: Storage) -> bool:
    for item in template.items():
        if not has(item):
            return false
    return true
