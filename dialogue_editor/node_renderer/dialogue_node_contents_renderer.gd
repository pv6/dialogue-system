tool
class_name DialogueNodeContentsRenderer
extends Control


export(bool) var disabled: bool setget set_disabled

var node: DialogueNode setget set_node


func _ready():
    size_flags_vertical = SIZE_EXPAND_FILL
    _update_contents()


static func _recursive_disable(node: Node, disabled: bool) -> void:
    for child in node.get_children():
        if "disabled" in child:
            child.disabled = disabled
        elif "readonly" in child:
            child.readonly = disabled
        else:
            _recursive_disable(child, disabled)


func update_size() -> void:
    pass


func set_disabled(new_disabled: bool) -> void:
    disabled = new_disabled
    _recursive_disable(self, new_disabled)


func set_node(new_node) -> void:
    if node:
        node.disconnect("contents_changed", self, "_update_contents")
    node = new_node
    if node:
        node.connect("contents_changed", self, "_update_contents")

    _on_set_node()
    _update_contents()


func _on_set_node() -> void:
    pass


func _update_contents() -> void:
    pass
