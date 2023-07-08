tool
class_name MyMenuButton
extends MenuButton


const CTRL := 0x1
const SHIFT := 0x2
const ALT := 0x4

var _button_signals := PoolStringArray()

var _last_index = 0

onready var _popup := get_popup()


func _ready() -> void:
    _popup.clear()
    _popup.connect("id_pressed", self, "_on_id_pressed")


func add_button(display_name: String, signal_name: String, scancode: int = -1, command_key_flags: int = 0) -> void:
    _popup.add_item(display_name, _last_index)
    if scancode != -1:
        var shortcut := ShortCut.new()
        shortcut.shortcut = InputEventKey.new()
        shortcut.shortcut.scancode = scancode
        shortcut.shortcut.control = (command_key_flags & CTRL) != 0
        shortcut.shortcut.shift = (command_key_flags & SHIFT) != 0
        shortcut.shortcut.alt = (command_key_flags & ALT) != 0
        _popup.set_item_shortcut(_popup.get_item_index(_last_index), shortcut)
    _button_signals.append(signal_name)
    _last_index += 1


func add_separator() -> void:
    _popup.add_separator()


func _on_id_pressed(id: int) -> void:
    assert(id >= 0 and id < _button_signals.size())
    emit_signal(_button_signals[id])
