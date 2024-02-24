tool
class_name DialogueNode
extends Clonable


signal id_changed(old_id, new_id)
signal contents_changed()

const DUMMY_ID := -1

export(Array) var children: Array
export(int) var id := DUMMY_ID setget set_id
export(int) var parent_id := DUMMY_ID

# DialogueNodeLogic
export(Resource) var condition_logic: Resource
# DialogueNodeLogic
export(Resource) var action_logic: Resource

export(String) var comment: String setget set_comment


func _init() -> void:
    condition_logic = DialogueNodeLogic.new()
    action_logic = DialogueNodeLogic.new()

    children = []


func set_id(new_id: int) -> void:
    var old_id := id
    id = new_id
    emit_signal("id_changed", old_id, new_id)


func set_comment(new_comment: String) -> void:
    if new_comment == comment:
        return
    comment = new_comment
    emit_signal("contents_changed")


func get_name() -> String:
    return "Node " + str(id)


func clone() -> Clonable:
    var copy := .clone() as DialogueNode
    copy.condition_logic = condition_logic.clone()
    copy.action_logic = action_logic.clone()
    return copy


func add_child(node: DialogueNode, position := -1) -> void:
    if position == -1:
        children.push_back(node)
    else:
        children.insert(position, node)
    node.parent_id = id


func remove_child(node: DialogueNode) -> void:
    var child_index = children.find(node)
    if child_index >= 0 and child_index < children.size():
        children.remove(child_index)
    node.parent_id = DUMMY_ID


func get_child_position(child_node: DialogueNode) -> int:
    return get_child_position_by_id(child_node.id)


func get_child_position_by_id(child_node_id: int) -> int:
    for i in range(children.size()):
        if children[i].id == child_node_id:
            return i
    return -1
