tool
extends MyMenuButton


signal open_global_tags_editor()


func _ready() -> void:
    add_button("Edit Global Tags...", "open_global_tags_editor")
