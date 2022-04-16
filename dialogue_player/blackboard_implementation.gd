class_name BlackboardImplementation
extends Resource


export(Resource) var template: Resource setget set_template
export(Dictionary) var data: Dictionary


func _init() -> void:
    data = {}


func set(name: String, value) -> void:
    assert(data.has(name))
    data[name] = value


func get(name: String):
    assert(data.has(name))
    return data[name]


func set_template(new_template: Blackboard) -> void:
    template = new_template
    data.clear()
    for flag_name in template.field_names.items():
        data[flag_name] = false
