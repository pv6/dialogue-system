class_name DisableableControl
extends Control


export(bool) var disabled := false setget set_disabled


#func _ready() -> void:
#    call_deferred("set_disabled", disabled)


static func _recursive_disable(node: Node, disabled: bool) -> void:
    for child in node.get_children():
        if "disabled" in child:
            child.disabled = disabled
        elif "readonly" in child:
            child.readonly = disabled
        elif "editable" in child:
            child.editable = not disabled
        elif child is Label:
            child.modulate.v = 0.5 if disabled else 1.0
        else:
            _recursive_disable(child, disabled)


func set_disabled(new_disabled: bool) -> void:
    disabled = new_disabled
    _recursive_disable(self, new_disabled)
