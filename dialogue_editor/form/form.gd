tool
class_name Form
extends VBoxContainer


export(PoolStringArray) var fields setget set_fields

var _field_edits := {}


var field_edit_scene = preload("field_edit.tscn")


func set_fields(new_fields: PoolStringArray) -> void:
    for child in get_children():
        remove_child(child)
    _field_edits.clear()

    fields = new_fields

    for field_name in fields:
        var field_edit := field_edit_scene.instance() as FieldEdit
        field_edit.field_name = field_name
        field_edit.value = field_name
        add_child(field_edit)
        _field_edits[field_name] = field_edit


func export_values(result) -> void:
    for field_name in fields:
        result.set(field_name, _field_edits[field_name].value)
