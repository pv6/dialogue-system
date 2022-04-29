tool
extends PanelContainer


signal delete_button_pressed()

export(String) var tag_name: String setget set_tag_name
export(bool) var disabled: bool setget set_disabled

onready var _label: Label = $HBoxContainer/Label
onready var _delete_button: IconButton = $HBoxContainer/DeleteButton


func _ready() -> void:
    self.tag_name = tag_name
    _delete_button.connect("pressed", self, "emit_signal", ["delete_button_pressed"])


func set_tag_name(new_tag_name: String) -> void:
    tag_name = new_tag_name
    if _label:
        _label.text = tag_name


func set_disabled(new_disabled: bool) -> void:
    disabled = new_disabled
    _delete_button.disabled = new_disabled
