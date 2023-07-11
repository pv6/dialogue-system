tool
class_name DialogueNodeContentsRenderer
extends DisableableControl


var node: DialogueNode setget set_node


func _ready():
    size_flags_vertical = SIZE_EXPAND_FILL
    # wait 1 frame for inherited nodes to initialize
    yield(get_tree(), "idle_frame")
    _update_contents()


# virtual
func update_size() -> void:
    pass


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
