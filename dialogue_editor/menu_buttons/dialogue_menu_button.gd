tool
extends MyMenuButton


signal new_dialogue()
signal open_dialogue()
signal save_dialogue()
signal save_dialogue_as()
signal undo()
signal redo()


func _ready() -> void:
    _add_button("New Dialogue", "new_dialogue", KEY_N, true)
    _add_button("Open Dialogue...", "open_dialogue", KEY_O, true)

    _popup.add_separator()

    _add_button("Save Dialogue", "save_dialogue", KEY_S, true)
    _add_button("Save Dialogue As...", "save_dialogue_as", KEY_S, true, true)

    _popup.add_separator()

    _add_button("Undo", "undo", KEY_Z, true)
    _add_button("Redo", "redo", KEY_Z, true, true)
