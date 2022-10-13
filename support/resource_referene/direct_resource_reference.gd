extends ResourceReference
class_name DirectResourceReference


export(Resource) var direct_reference


func _init(direct_reference: Resource = null) -> void:
    self.direct_reference = direct_reference
    

func get_resource() -> Resource:
    return direct_reference

    
func set_resource(new_resource: Resource) -> void:
    direct_reference = new_resource

