tool
extends HBoxContainer


export(bool) var disabled := false setget set_disabled

onready var flag_picker: FlagPicker = $FlagPicker
onready var remove_button: IconButton = $RemoveButton


func set_disabled(value: bool) -> void:
    disabled = value
    flag_picker.disabled = value
    remove_button.disabled = value
