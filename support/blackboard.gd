tool
class_name Blackboard
extends Resource


export(Resource) var field_names setget set_field_names

var name: String setget ,get_name


func _init() -> void:
    self.field_names = Storage.new()


func _to_string() -> String:
    return get_name()


func get_name() -> String:
    # I AM SORRY OK
    # NAME NEEDS TO UPDATE IF FILE NAME CHANGES, HENCE GETTER
    var ext = "." + resource_path.get_extension()
    var filename := resource_path.get_file().trim_suffix("." + resource_path.get_extension())
    if filename != "" and not ":" in ext:
        return filename
    # BUT CUSTOMIZABLE EXPORTED NAME GETS BUGGED TO HELL
    # SO IT'S THIS OR NOTHING BABY IT'S THIS OR NOTHING
    return "local_blackboard"


func set_field_names(new_field_names: Storage) -> void:
    if field_names and field_names.is_connected("changed", self, "emit_changed"):
        field_names.disconnect("changed", self, "emit_changed")
    field_names = new_field_names
    if field_names and not field_names.is_connected("changed", self, "emit_changed"):
        field_names.connect("changed", self, "emit_changed")
    emit_changed()


func clone() -> Blackboard:
    var copy := get_script().new() as Blackboard

    copy.field_names = field_names.clone()

    return copy
