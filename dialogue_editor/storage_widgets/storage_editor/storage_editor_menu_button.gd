tool
extends MyMenuButton


signal undo()
signal redo()


func _ready() -> void:
    add_button("Undo", "undo", KEY_Z, CTRL)
    add_button("Redo", "redo", KEY_Z, CTRL | SHIFT)
