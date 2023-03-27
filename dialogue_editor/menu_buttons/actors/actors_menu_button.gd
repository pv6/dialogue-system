tool
extends MyMenuButton


signal open_dialogue_actors_editor()
signal open_global_actors_editor()


func _ready() -> void:
    _add_button("Edit Dialogue Actors...", "open_dialogue_actors_editor")
    _popup.add_separator()
    _add_button("Edit Global Actors...", "open_global_actors_editor")
