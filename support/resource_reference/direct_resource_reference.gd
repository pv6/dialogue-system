tool
extends ResourceReference
class_name DirectResourceReference


export(Resource) var direct_reference: Resource setget set_direct_reference


func _init(direct_reference: Resource = null) -> void:
    self.direct_reference = direct_reference


func set_resource(new_resource: Resource) -> void:
    self.direct_reference = new_resource


func set_direct_reference(new_direct_reference: Resource) -> void:
    if direct_reference:
        direct_reference.disconnect("changed", self, "emit_changed")
    direct_reference = new_direct_reference
    if direct_reference:
        direct_reference.connect("changed", self, "emit_changed")
    emit_changed()


func _get_resource() -> Resource:
    return direct_reference
