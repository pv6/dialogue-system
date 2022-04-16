tool
class_name CombinedDialogueNodeContentsRenderer
extends DialogueNodeContentsRenderer


var child_contents := []


func add_child_contents(contents: DialogueNodeContentsRenderer) -> void:
    if not contents:
        return

    # add separator if not first contents
    if child_contents.size() > 0:
        add_child(HSeparator.new())

    child_contents.push_back(contents)
    
    # add as child, then set node, so contents' children are created
    add_child(contents)
    contents.node = node


func _on_set_node() -> void:
    for child in child_contents:
        child.node = node


func _update_contents() -> void:
    for child in child_contents:
        child._update_contents()
