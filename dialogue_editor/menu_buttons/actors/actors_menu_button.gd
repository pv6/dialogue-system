tool
extends MyMenuButton


signal open_dialogue_actors_editor()
signal open_project_actors_editor()


func _ready() -> void:
    add_button("Edit Dialogue Actors...", "open_dialogue_actors_editor")
    add_separator()
    add_button("Edit Project Actors...", "open_project_actors_editor")
