tool
class_name Dialogue
extends Clonable


signal nodes_changed()
signal blackboards_changed()

export(String) var description

# '_local_blackboard_ref' is positioned above 'root_node' because it needs to be
# copied in 'duplicate' before 'root_node' for auto flags to be set up properply sorryyy
# DirectResourceReference, so that could be changed in StorageEditor
export(Resource) var _local_blackboard_ref: Resource setget _set_local_blackboard_ref
# DialogueNode
export(Resource) var root_node: Resource setget set_root_node
# Storage that contains StorageItems pointing to global actors storage
export(Resource) var actors: Resource
# Storage that contains ResourceReferences pointing to storages
export(Resource) var blackboards: Resource setget set_blackboards

export(int) var max_id := 0

export(String) var editor_version = "0.0.0"

# id -> node
var nodes := {}


func _init() -> void:
    actors = Storage.new()
    blackboards = Storage.new()

    self._local_blackboard_ref = DirectResourceReference.new(Storage.new())

    root_node = RootDialogueNode.new()
    root_node.id = get_new_max_id()
    self.root_node = root_node


func _set_local_blackboard_ref(new_local_blackboard_ref: DirectResourceReference) -> void:
    _local_blackboard_ref = new_local_blackboard_ref

    if blackboards.has_id(0):
        blackboards.set_item(0, _local_blackboard_ref)
    else:
        blackboards.add_item(_local_blackboard_ref)
        blackboards.lock_item(0)

    emit_changed()


func get_new_max_id() -> int:
    max_id += 1
    return max_id - 1


func set_blackboards(new_blackboards: Storage) -> void:
    if blackboards != new_blackboards:
        blackboards = new_blackboards
        emit_signal("blackboards_changed")


func add_blackboard(blackboard: Storage) -> int:
    var blackboard_reference = ExternalResourceReference.new()
    blackboard_reference.external_path = blackboard.resource_path
    return blackboards.add_item(blackboard_reference)


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

    _update_auto_flags()
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


func clone() -> Clonable:
    var copy := duplicate() as Dialogue

    # copy blackboard templates
    copy.blackboards = blackboards.clone()
    # copy actor storage
    copy.actors = actors.clone()

    # copy all nodes for references to exist
    for node in nodes.values():
        var copy_node = node.clone()

        # update 'blackboards' direct reference in nodes flags
        _update_flags(copy_node, copy)
        # update 'actors' direct reference in speaker and listener
        _update_actors(copy_node, copy)

        copy.nodes[node.id] = copy_node

    # set new child references
    for copy_node in copy.nodes.values():
        var orig_node := nodes[copy_node.id] as DialogueNode
        copy_node.children.clear()
        for child_node in orig_node.children:
            copy_node.children.push_back(copy.nodes[child_node.id])

    # set root node
    copy._set_root_node_directly(copy.nodes[root_node.id])

    # copy local blackboard (both ResourceReference and Storage within)
    copy._local_blackboard_ref = _local_blackboard_ref.clone()
    copy._local_blackboard_ref.direct_reference = _local_blackboard_ref.direct_reference.clone()

    return copy


func get_local_blackboard_ref() -> StorageItemResourceReference:
    return StorageItemResourceReference.new(blackboards.get_item_reference(0))


# child_nodes: Array[DialogueNode]
func make_children_of_node(new_child_nodes: Array, new_parent: DialogueNode, reparent_with_children: bool) -> bool:
    # check we were passed nodes from THIS dialogue
    assert(nodes[new_parent.id] == new_parent)

    if new_parent is ReferenceDialogueNode:
        print("Can't make child of reference node!")
        return false

    var made_changes := false

    for new_child in new_child_nodes:
        # check we were passed nodes from THIS dialogue
        assert(nodes[new_child.id] == new_child)

        if new_child is RootDialogueNode:
            print("Can't make parent of root node!")
            continue

        if not nodes.has(new_child.parent_id):
            print("Node %d has no parent!" % new_child.id)
            continue

        var need_reparent_old_children: bool = not reparent_with_children and not new_child.children.empty()
        var already_last_child: bool = not new_parent.children.empty() and new_parent.children[-1] == new_child
        if not need_reparent_old_children and already_last_child:
            print("Already last child of parent!")
            continue

        if new_child.id == new_parent.id:
            print("Can't make child of self!")
            continue

        var old_parent: DialogueNode = nodes[new_child.parent_id]

        if reparent_with_children:
            if is_in_branch(new_parent, new_child):
                print("New parent %d is within node %d subtree!" % [new_parent.id, new_child.id])
                continue
        else:
            var pos := old_parent.children.find(new_child)
            while not new_child.children.empty():
                var child: DialogueNode = new_child.children[-1]
                new_child.remove_child(child)
                old_parent.add_child(child, pos)

        old_parent.remove_child(new_child)
        new_parent.add_child(new_child)
        made_changes = true

    if not made_changes:
        return false

    update_nodes()
    return true


func make_parent_of_node(new_parent: DialogueNode, new_child: DialogueNode, keep_old_children: bool) -> bool:
    # check we were passed nodes from THIS dialogue
    assert(nodes[new_parent.id] == new_parent)
    assert(nodes[new_child.id] == new_child)

    if new_parent is ReferenceDialogueNode:
        print("Can't make child of reference node!")
        return false

    if new_child is RootDialogueNode:
        print("Can't make parent of root node!")
        return false

    if not nodes.has(new_child.parent_id):
        print("Node %d has no parent!" % new_child.id)
        return false

    if new_parent.id == new_child.parent_id and (keep_old_children or new_parent.children.size() == 1):
        print("Already parent of child!")
        return false

    var old_parent_of_new_parent: DialogueNode = nodes[new_parent.parent_id]

    if not keep_old_children:
        # assign new parent's children to it's old parent
        var pos := old_parent_of_new_parent.children.find(new_parent)
        while not new_parent.children.empty():
            var child: DialogueNode = new_parent.children[-1]
            new_parent.remove_child(child)
            old_parent_of_new_parent.add_child(child, pos)

    var old_parent: DialogueNode = nodes[new_child.parent_id]
    var new_child_old_pos := old_parent.children.find(new_child)

    old_parent_of_new_parent.remove_child(new_parent)
    old_parent.remove_child(new_child)
    old_parent.add_child(new_parent, new_child_old_pos)
    new_parent.add_child(new_child)

    update_nodes()
    return true


func drag_onto_node(dragged_node: DialogueNode, dragged_onto_node: DialogueNode) -> bool:
    # move up if dragged onto parent while only child
    if dragged_onto_node.children.size() == 1 and dragged_onto_node.children[0] == dragged_node:
        return make_parent_of_node(dragged_node, dragged_onto_node, false)

    # become only child of dragged onto node
    if dragged_onto_node.children.empty():
        return make_children_of_node([dragged_node], dragged_onto_node, false)

    # become only child of dragged onto node and inherit its old children
    # make last child of dragged onto node (abandoning dragged node's old children)
    var need_to_move_dragged: bool = dragged_onto_node.children[-1] != dragged_node or not dragged_node.children.empty()
    if need_to_move_dragged and not make_children_of_node([dragged_node], dragged_onto_node, false):
        return false
    # inherit old children of dragged onto node
    return make_children_of_node(dragged_onto_node.children.slice(0, dragged_onto_node.children.size() - 2), dragged_node, true)


func is_in_branch(node: DialogueNode, branch_root: DialogueNode) -> bool:
    if node == branch_root:
        return true

    for child in branch_root.children:
        if is_in_branch(node, child):
            return true

    return false


# return Array[DialogueNode]
func get_nodes(ids: PoolIntArray) -> Array:
    var output := []
    for id in ids:
        if nodes.has(id):
            output.push_back(nodes[id])
    return output


func _update_auto_flags() -> void:
    for node in nodes.values():
        var visited_flag_name = "auto_visited_node_%d" % node.id
        var flag_id = _local_blackboard_ref.resource.add_item(visited_flag_name)
        if flag_id == -1:
            continue

        _local_blackboard_ref.resource.hide_item(flag_id)

        # set visited flag to true on action
        var visited_flag := DialogueFlag.new()
        visited_flag.blackboard = get_local_blackboard_ref()
        visited_flag.field_id = flag_id
        visited_flag.value = true
        node.action_logic.auto_flags.push_back(visited_flag)


func _set_root_node_directly(new_root_node: DialogueNode) -> void:
    root_node = new_root_node


func _update_flags(copy_node: DialogueNode, copy: Dialogue) -> void:
    var logics = ["condition", "action"]
    var flags = ["", "auto_"]
    for logic_type in logics:
        for flag_type in flags:
            for flag in copy_node.get(logic_type + "_logic").get(flag_type + "flags"):
                if flag.blackboard:
                    flag.blackboard.storage_item.storage_reference.direct_reference = copy.blackboards


func _update_actors(copy_node: DialogueNode, copy: Dialogue) -> void:
    if copy_node is TextDialogueNode:
        var actors = ["speaker", "listener"]
        for actor_type in actors:
            if copy_node.get(actor_type):
                copy_node.get(actor_type).storage_reference.direct_reference = copy.actors
