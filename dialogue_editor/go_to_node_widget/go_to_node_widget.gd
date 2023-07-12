tool
extends ConfirmationDialog


signal go_to_node(id)

const WRONG_INPUT_ICON := preload("res://addons/dialogue_system/assets/icons/close.svg")

# Set[int] aka Dictionary[int, int]
var valid_ids := {}

onready var _line_edit: LineEdit = $"%LineEdit"


func get_id() -> int:
    if not _line_edit or not _line_edit.text.is_valid_integer():
        return -1
    return int(_line_edit.text)


func is_id_valid(id: int = get_id()) -> bool:
    return valid_ids.has(id)


func confirm() -> void:
    var id = get_id()
    if is_id_valid(id):
        emit_signal("go_to_node", id)
        hide()


func _check_input() -> void:
    if is_id_valid():
       _line_edit.right_icon = null
    else:
        _line_edit.right_icon = WRONG_INPUT_ICON


func _on_line_edit_text_changed(new_text: String) -> void:
    _check_input()


func _on_line_edit_text_entered(new_text: String) -> void:
    confirm()


func _on_confirmed() -> void:
    confirm()


func _on_about_to_show() -> void:
    _line_edit.clear()
    _check_input()
    yield(get_tree(), "idle_frame")
    _line_edit.grab_focus()
