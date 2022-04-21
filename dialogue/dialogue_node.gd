tool
class_name DialogueNode
extends Resource


signal id_changed(old_id, new_id)
signal contents_changed()

const DUMMY_ID := -1

export(Array) var children: Array
export(int) var id := DUMMY_ID setget set_id
export(int) var parent_id := DUMMY_ID

export(Resource) var condition_logic: Resource
export(Resource) var action_logic: Resource

export(String) var comment: String setget set_comment


func _init() -> void:
    condition_logic = DialogueNodeLogic.new()
    action_logic = DialogueNodeLogic.new()

    # this was a bug, for SOME reason children was null without it, don't remove
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


func clone() -> DialogueNode:
    var out := duplicate() as DialogueNode
    out.condition_logic = condition_logic.clone()
    out.action_logic = action_logic.clone()
    return out


func add_child(node) -> void:
    children.push_back(node)
    node.parent_id = id
