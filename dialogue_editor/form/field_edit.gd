tool
class_name FieldEdit
extends HBoxContainer


signal value_changed(new_value)
signal field_name_changed(new_field_name)

export(String) var field_name: String = "field_name" setget set_field_name
export(String) var value: String = "value" setget set_value

onready var _label: Label = $Label
onready var _text_edit: TextEdit = $TextEdit


func _ready():
    if not is_connected("renamed", self, "_on_renamed"):
        connect("renamed", self, "_on_renamed")
    if not _text_edit.is_connected("text_changed", self, "_on_text_changed"):
        _text_edit.connect("text_changed", self, "_on_text_changed")

    self.field_name = field_name
    self.value = value


func set_field_name(new_field_name: String) -> void:
    var old_field_name := field_name
    field_name = new_field_name
    if field_name != old_field_name:
        emit_signal("field_name_changed", new_field_name)
    if _label:
        _label.text = field_name


func _on_text_changed() -> void:
    self.value = _text_edit.text


func set_value(new_value: String) -> void:
    var old_value := value
    value = new_value
    if old_value != new_value:
        emit_signal("value_changed", new_value)
    if _text_edit and _text_edit.text != value:
        _text_edit.text = value


func _on_renamed() -> void:
    self.field_name = get_name()
