tool
class_name UnfocusableTextEdit
extends TextEdit


var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


func _input(event: InputEvent) -> void:
    if not event is InputEventKey or get_focus_owner() != self:
        return

    if event.scancode == KEY_ESCAPE:
        release_focus()
        _session.focus_graph_renderer()

        get_tree().set_input_as_handled()
