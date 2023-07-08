tool
class_name CombinedDialogueNodeContentsRenderer
extends DialogueNodeContentsRenderer


# Array[DialogueNodeContentsRenderer]
var child_contents := []

# Dictionary[Script, DialogueNodeContentsRenderer]
var _node_type_to_contents := {}


func add_child_contents(contents: DialogueNodeContentsRenderer, node_type: Script = null) -> void:
    if not contents:
        return

    # add separator if not first contents
    if child_contents.size() > 0:
        add_child(HSeparator.new())

    child_contents.push_back(contents)

    if node_type:
        assert(not _node_type_to_contents.has(node_type))
        _node_type_to_contents[node_type] = contents

    # add as child first, so contents' children are created, then set node
    add_child(contents)
    contents.node = node


func update_size() -> void:
    for contents in child_contents:
        contents.update_size()


func get_contents_by_node_type(node_type: Script) -> DialogueNodeContentsRenderer:
    if _node_type_to_contents.has(node_type):
        return _node_type_to_contents[node_type]
    return null


func _on_set_node() -> void:
    for child in child_contents:
        child.node = node


func _update_contents() -> void:
    for child in child_contents:
        child._update_contents()
