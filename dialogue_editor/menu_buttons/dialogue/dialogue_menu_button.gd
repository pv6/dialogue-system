tool
extends MyMenuButton


signal new_dialogue()
signal open_dialogue()

signal save_dialogue()
signal save_dialogue_as()

signal undo()
signal redo()

signal close_dialogue()
signal next_dialogue()
signal previous_dialogue()


func _ready() -> void:
    add_button("New Dialogue", "new_dialogue", KEY_N, CTRL)
    add_button("Open Dialogue...", "open_dialogue", KEY_O, CTRL)

    add_separator()

    add_button("Save Dialogue", "save_dialogue", KEY_S, CTRL)
    add_button("Save Dialogue As...", "save_dialogue_as", KEY_S, CTRL | SHIFT)

    add_separator()

    add_button("Undo", "undo", KEY_Z, CTRL)
    add_button("Redo", "redo", KEY_Z, CTRL | SHIFT)

    add_separator()

    add_button("Close Dialogue", "close_dialogue", KEY_W, CTRL)
    add_button("Next Dialogue", "next_dialogue", KEY_TAB, CTRL)
    add_button("Previous Dialogue", "previous_dialogue", KEY_TAB, CTRL | SHIFT)
