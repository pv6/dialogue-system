tool
class_name Dialogue
extends Resource


signal nodes_changed()
signal blackboards_changed()

export(String) var description

export(Resource) var root_node: Resource setget set_root_node
export(Resource) var actors: Resource
export(Resource) var blackboards: Resource setget set_blackboards

export(Resource) var local_blackboard: Resource

export(int) var max_id := 0

export(String) var editor_version = "0.0.0"


# id -> node
var nodes := {}


func _init() -> void:
    actors = Storage.new()
    blackboards = Storage.new()

    local_blackboard = Blackboard.new()
    blackboards.add_item(local_blackboard)
    blackboards.lock_item(0)

    root_node = RootDialogueNode.new()
    root_node.id = get_new_max_id()
    self.root_node = root_node


func get_new_max_id() -> int:
    max_id += 1
    return max_id - 1


func set_blackboards(new_blackboards: Storage) -> void:
    if blackboards != new_blackboards:
        blackboards = new_blackboards
        emit_signal("blackboards_changed")


func get_node(node_id: int) -> DialogueNode:
    if not nodes.has(node_id):
        return null
    return nodes[node_id]


func update_nodes() -> void:
    nodes.clear()
    if root_node:
        var node_stack := [root_node]
        while not node_stack.empty():
            var cur_node := node_stack.pop_back() as DialogueNode
            assert(cur_node)

            nodes[cur_node.id] = cur_node

            for child_node in cur_node.children:
                assert(child_node as DialogueNode)
                assert(not nodes.has(child_node.id))
                node_stack.push_back(child_node)
    emit_signal("nodes_changed")


func get_nodes_by_ids(ids: Array) -> Array:
    var output := []
    for id in ids:
        if nodes.has(id):
            output.push_back(nodes[id])
    return output


func set_root_node(new_root_node: DialogueNode) -> void:
    root_node = new_root_node
    update_nodes()


func clone() -> Dialogue:
    var copy := get_script().new() as Dialogue

    copy.max_id = max_id
    copy.editor_version = editor_version

    # copy all nodes for references to exist
    for node in nodes.values():
        copy.nodes[node.id] = node.clone()

    # set new child-parent references
    assert(root_node)
    var id_stack := [root_node.id]
    while not id_stack.empty():
        var cur_id = id_stack.pop_front()

        var orig_node := nodes[cur_id] as DialogueNode
        var copy_node := copy.nodes[cur_id] as DialogueNode

        # set children references
        copy_node.children.clear()
        for child_node in orig_node.children:
            copy_node.children.push_back(copy.nodes[child_node.id])
            id_stack.push_back(child_node.id)

        # set reference node reference
        var orig_ref_node := orig_node as ReferenceDialogueNode
        if orig_ref_node:
            var copy_ref_node := copy_node as ReferenceDialogueNode
            assert(copy_ref_node)
            copy_ref_node.referenced_node_id = orig_ref_node.referenced_node_id

    # set root node
    copy.root_node = copy.nodes[root_node.id]

    # copy actor storage
    copy.actors = actors.clone()

    # copy blackboard templates
    copy.blackboards = blackboards.clone()

    # copy local blackboard and replace reference in blackboards storage
    copy.local_blackboard = local_blackboard.clone()
    copy.blackboards.set_item(0, copy.local_blackboard)

    return copy
