extends ResourceReference
class_name ExternalResourceReference


export(String) var external_path: String


func get_resource() -> Resource:
    return ResourceLoader.load(external_path)
