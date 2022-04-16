tool
class_name DialogueFlag
extends Resource


export(Resource) var blackboard setget set_blackboard
export(int) var id := -1 setget set_id
export(bool) var value := true setget set_value

var name: String setget ,get_name


func set_blackboard(new_blackboard: Blackboard) -> void:
    if new_blackboard == blackboard:
        return

    if blackboard:
        blackboard.disconnect("changed", self, "emit_changed")
    blackboard = new_blackboard
    if blackboard:
        blackboard.connect("changed", self, "emit_changed")

    id = -1
    emit_changed()


func set_id(new_id: int) -> void:
    if id == new_id:
        return
    id = new_id
    emit_changed()


func set_value(new_value: bool) -> void:
    if value == new_value:
        return
    value = new_value
    emit_changed()


func get_name() -> String:
    if blackboard and id in blackboard.field_names.ids():
        return blackboard.field_names.get_item(id)
    return ""
