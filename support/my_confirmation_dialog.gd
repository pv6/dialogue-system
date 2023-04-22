tool
class_name MyConfirmationDialog
extends ConfirmationDialog


signal canceled()


func _ready() -> void:
    get_cancel().connect("pressed", self, "emit_signal", ["canceled"])
    get_close_button().connect("pressed", self, "emit_signal", ["canceled"])

