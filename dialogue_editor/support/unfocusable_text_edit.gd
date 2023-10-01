tool
class_name UnfocusableTextEdit
extends TextEdit


var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


func _input(event: InputEvent) -> void:
    if not event is InputEventKey or not has_focus():
        return

    if event.scancode == KEY_ESCAPE or event.is_pressed() and event.scancode == KEY_ENTER and not Input.is_key_pressed(KEY_CONTROL):
        release_focus()
        _session.focus_graph_renderer()

        get_tree().set_input_as_handled()
