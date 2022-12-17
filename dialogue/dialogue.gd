tool
class_name Dialogue
extends Clonable


signal nodes_changed()
signal blackboards_changed()

export(String) var description

# DialogueNode
export(Resource) var root_node: Resource setget set_root_node
# Storage that contains StorageItems pointing to global actors storage
export(Resource) var actors: Resource
# Storage that contains ResourceReferences pointing to storages
export(Resource) var blackboards: Resource setget set_blackboards

export(int) var max_id := 0

export(String) var editor_version = "0.0.0"

# DirectResourceReference, so that could be changed in StorageEditor
export(Resource) var _local_blackboard_ref: Resource setget _set_local_blackboard_ref

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
        var logics = ["condition", "action"]
        var flags = ["", "auto_"]
        for logic_type in logics:
            for flag_type in flags:
                for flag in copy_node.get(logic_type + "_logic").get(flag_type + "flags"):
                    if flag.blackboard:
                        flag.blackboard.storage_item.storage_reference.direct_reference = copy.blackboards
        # update 'actors' direct reference in speaker and listener
        if copy_node is TextDialogueNode:
            var actors = ["speaker", "listener"]
            for actor_type in actors:
                if copy_node.get(actor_type):
                    copy_node.get(actor_type).storage_reference.direct_reference = copy.actors


        copy.nodes[node.id] = copy_node

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

    # copy local blackboard (both ResourceReference and Storage within)
    copy._local_blackboard_ref = _local_blackboard_ref.clone()
    copy._local_blackboard_ref.direct_reference = _local_blackboard_ref.direct_reference.clone()

    return copy


func get_local_blackboard_ref() -> StorageItemResourceReference:
    return StorageItemResourceReference.new(blackboards.get_item_reference(0))


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

