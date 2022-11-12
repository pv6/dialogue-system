tool
class_name StorageImplementation
extends Resource


# Storage
export(Resource) var template: Resource setget set_template
export(Dictionary) var data: Dictionary


func _init(template: Storage = null) -> void:
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


func set_template(new_template: Storage) -> void:
    template = new_template
    data = {}
    if template:
        for item in template.items():
            data[str(item)] = false
    property_list_changed_notify()
            
            
func is_valid(template: Storage) -> bool:
    for item in template.items():
        if not has(item):
            return false
    return true
