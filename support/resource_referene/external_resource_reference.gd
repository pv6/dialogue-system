extends ResourceReference
class_name ExternalResourceReference


export(String) var external_path: String


func _init(external_path: String = "") -> void:
    self.external_path = external_path
    

func get_resource() -> Resource:
    return ResourceLoader.load(external_path)


func set_resource(new_resource: Resource) -> void:
    ResourceSaver.save(external_path, new_resource)
