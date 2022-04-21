tool
class_name MyMenuButton
extends MenuButton


var _button_signals := PoolStringArray()

var _last_index = 0

onready var _popup := get_popup()


func _ready() -> void:
    _popup.clear()
    _popup.connect("id_pressed", self, "_on_id_pressed")


func _add_button(display_name: String, signal_name: String, scancode: int = -1, is_control := false,
        is_shift := false, is_alt := false) -> void:
    _popup.add_item(display_name, _last_index)
    if scancode != -1:
        var shortcut := ShortCut.new()
        shortcut.shortcut = InputEventKey.new()
        shortcut.shortcut.scancode = scancode
        shortcut.shortcut.control = is_control
        shortcut.shortcut.shift = is_shift
        shortcut.shortcut.alt = is_alt
        _popup.set_item_shortcut(_popup.get_item_index(_last_index), shortcut)
    _button_signals.append(signal_name)
    _last_index += 1


func _on_id_pressed(id: int) -> void:
    assert(id >= 0 and id < _button_signals.size())
    emit_signal(_button_signals[id])
