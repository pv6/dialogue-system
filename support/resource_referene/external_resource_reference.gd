extends ResourceReference
class_name ExternalResourceReference


export(String) var external_path: String setget set_external_path


func _init(external_path: String = "") -> void:
    self.external_path = external_path
  

func set_resource(new_resource: Resource) -> void:
    ResourceSaver.save(external_path, new_resource)
    emit_changed()


func set_external_path(new_external_path: String) -> void:
    if new_external_path != external_path:
        external_path = new_external_path
        emit_changed()


func _get_resource() -> Resource:
    return ResourceLoader.load(external_path)
