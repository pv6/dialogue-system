tool
extends MyMenuButton


signal open_dialogue_blackboards_editor()
signal open_blackboard_editor()


func _ready() -> void:
    _add_button("Edit Dialogue Blackboards...", "open_dialogue_blackboards_editor")
    _popup.add_separator()
    _add_button("Edit Blackboard...", "open_blackboard_editor")

