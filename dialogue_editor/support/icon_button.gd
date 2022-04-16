tool
class_name IconButton
extends ToolButton


export(bool) var highlighted := false setget set_highlighted


func _init() -> void:
    if not is_connected("mouse_entered", self, "_on_mouse_entered"):
        connect("mouse_entered", self, "_on_mouse_entered")
    if not is_connected("mouse_exited", self, "_on_mouse_exited"):
        connect("mouse_exited", self, "_on_mouse_exited")


func set_highlighted(new_highlighted: bool) -> void:
    highlighted = new_highlighted
    if highlighted:
        modulate.v = 2
    else:
        modulate.v = 1


func _on_mouse_entered() -> void:
    highlighted = true


func _on_mouse_exited() -> void:
    highlighted = false
