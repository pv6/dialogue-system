tool
extends Tabs


signal tab_add()

export(bool) var show_add_button := true setget set_show_add_button

onready var _add_button: Button = $AddButton


func add_tab(title: String = "", icon: Texture = null) -> void:
    .add_tab(title, icon)
    call_deferred("_update_width")


func set_tab_title(tab_index: int, new_title: String) -> void:
    .set_tab_title(tab_index, new_title)
    call_deferred("_update_width")


func remove_tab(tab_index: int) -> void:
    .remove_tab(tab_index)
    call_deferred("_update_width")


func set_show_add_button(value: bool) -> void:
    if show_add_button == value:
        return
    show_add_button = value
    if show_add_button:
        _add_button.show()
    else:
        _add_button.hide()


func _update_width() -> void:
    _add_button.margin_left = _calculate_width()


func _calculate_width() -> float:
    var output := 0.0
    for i in range(get_tab_count()):
        output += get_tab_rect(i).size.x
    return output
