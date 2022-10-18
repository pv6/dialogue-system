tool
extends Resource
class_name ResourceReference


var resource: Resource setget set_resource, get_resource


func _to_string():
    return str(get_resource())
    

func get_resource() -> Resource:
    var res = _get_resource()
    if res and res.has_method("get_resource"):
        return res.get_resource()
    return res


func set_resource(new_resource: Resource) -> void:
    pass


func equals(other: ResourceReference) -> bool:
    var resource = get_resource()

    # if resource exists
    if resource:
        # try using 'equals' method
        if resource.has_method("equals"):
            return other and resource.equals(other.get_resource())
        # compare references directly
        return other and resource == other.get_resource()

    # if resource doesn't exist, other should be null or contain null
    return not other or not other.get_resource()


func clone() -> ResourceReference:
    var copy = duplicate()
    return copy


func _get_resource() -> Resource:
    return null
