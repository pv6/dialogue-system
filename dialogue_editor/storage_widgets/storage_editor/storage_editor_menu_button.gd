tool
extends MyMenuButton


signal undo()
signal redo()


func _ready() -> void:
    _add_button("Undo", "undo", KEY_Z, true)
    _add_button("Redo", "redo", KEY_Z, true, true)
