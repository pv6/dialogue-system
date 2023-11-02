tool
extends "saver.gd"


# virtual
func save(object: Resource, path: String) -> void:
    ResourceSaver.save(path, object, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)


# virtual
func load(path: String) -> Reference:
    return ResourceLoader.load(path, "", true)
