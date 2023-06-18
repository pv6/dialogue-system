tool
class_name DialogueFlag
extends Clonable


export(bool) var value := true setget set_value


func _to_string() -> String:
    return ""


func set_value(new_value: bool) -> void:
    if value == new_value:
        return
    value = new_value
    emit_changed()


# virtual
func check(input: DialogueNodeLogicInput) -> bool:
    return true
