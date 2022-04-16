tool
class_name DialogueNodeContentsRenderer
extends VBoxContainer


var node: DialogueNode setget set_node


func _ready():
    _update_contents()


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
