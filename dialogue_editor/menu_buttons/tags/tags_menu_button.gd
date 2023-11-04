tool
extends MyMenuButton


signal open_project_tags_editor()


func _ready() -> void:
    add_button("Edit Project Tags...", "open_project_tags_editor")
