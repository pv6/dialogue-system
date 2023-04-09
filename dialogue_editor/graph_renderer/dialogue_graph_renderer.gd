tool
class_name DialogueGraphRenderer
extends GraphEdit


signal collapsed_nodes_changed()

const NODE_RENDERER_SCENE := preload("../node_renderer/dialogue_node_renderer.tscn")
const CACHED_RENDERER_OFFSET := Vector2(-690, 0)

export(int) var vertical_spacing := 30
export(int) var horizontal_spacing := 30
export(float) var dragging_percentage := 0.69

# Dialogue
export(Resource) var dialogue: Resource setget set_dialogue

export(Array) var selected_node_ids: Array setget set_selected_node_ids, get_selected_node_ids

# node id -> renderer
var node_renderers: Dictionary

# Set of ids
var collapsed_nodes: Dictionary

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

var _cached_node_heights := {}
var _cached_children_heights := {}

var _cached_node_renderers: Array
var _used_node_renderers: int


func _init() -> void:
    collapsed_nodes = {}
    node_renderers = {}


func set_dialogue(new_dialogue: Dialogue) -> void:
    if dialogue:
        if dialogue.is_connected("nodes_changed", self, "update_graph"):
            dialogue.disconnect("nodes_changed", self, "update_graph")
    dialogue = new_dialogue
    if dialogue:
        if not dialogue.is_connected("nodes_changed", self, "update_graph"):
            dialogue.connect("nodes_changed", self, "update_graph")
    update_graph()


func get_selected_node_ids() -> Array:
    var out := []
    for renderer in node_renderers.values():
        if renderer.selected:
            out.push_back(renderer.node.id)
    return out


func set_selected_node_ids(new_ids: Array) -> void:
    var old_ids = self.selected_node_ids
    for id in old_ids:
        node_renderers[id].selected = false
    for id in new_ids:
        node_renderers[id].selected = true


func deselect_all() -> void:
    set_selected_node_ids([])


func collapse_node(node: DialogueNode) -> void:
    if collapsed_nodes.has(node.id):
        return

    collapsed_nodes[node.id] = true
    update_graph()
    emit_signal("collapsed_nodes_changed")


func uncollapse_node(node: DialogueNode) -> void:
    if not collapsed_nodes.has(node.id):
        return

    collapsed_nodes.erase(node.id)
    update_graph()
    emit_signal("collapsed_nodes_changed")


# nodes: Array[DialogueNode]
func collapse_nodes(nodes: Array) -> void:
    var made_changes := false

    for node in nodes:
        if collapsed_nodes.has(node.id):
            continue
        collapsed_nodes[node.id] = true
        made_changes = true

    if made_changes:
        update_graph()
        emit_signal("collapsed_nodes_changed")


# nodes: Array[DialogueNode]
func uncollapse_nodes(nodes: Array) -> void:
    var made_changes := false

    for node in nodes:
        if not collapsed_nodes.has(node.id):
            continue
        collapsed_nodes.erase(node.id)
        made_changes = true

    if made_changes:
        update_graph()
        emit_signal("collapsed_nodes_changed")


func update_node_sizes() -> void:
    for renderer in node_renderers.values():
        renderer.contents.update_size()
        renderer.rect_size = _session.settings.node_min_size
    call_deferred("_update_renderer_offsets")


func update_graph() -> void:
    # save selected node ids (node references get deprecated on dialogue cloning)
    var selected := self.selected_node_ids

    # disconnect child nodes
    for node_renderer_a in node_renderers.values():
        for node_renderer_b in node_renderers.values():
            disconnect_node(node_renderer_a.name, 0, node_renderer_b.name, 0)

    # remove old renderers
    node_renderers.clear()

    if not dialogue:
        return
    assert(dialogue.root_node)

    # create node renderers
    var old_used_renderers = _used_node_renderers
    _recursively_add_node_renderers(dialogue.root_node)
    if _session.settings.cache_unused_node_renderers:
        for i in range(_used_node_renderers, old_used_renderers):
            _reset_node_renderer(_cached_node_renderers[i])
    else:
        for i in range(_used_node_renderers, _cached_node_renderers.size()):
            _cached_node_renderers[i].queue_free()
        _cached_node_renderers.resize(_used_node_renderers)

    # restore selected nodes
    for id in selected:
        if dialogue.nodes.has(id) and node_renderers.has(id):
            node_renderers[id].selected = true

    # connect child nodes
    for node_renderer in node_renderers.values():
        if collapsed_nodes.has(node_renderer.node.id):
            continue
        for child in node_renderer.node.children:
            connect_node(node_renderer.name, 0, node_renderers[child.id].name, 0)

    _update_renderer_offsets()
    call_deferred("update_node_sizes")


func _update_renderer_offsets() -> void:
    _cached_node_heights = {}
    _cached_children_heights = {}

    _calculate_children_local_offset(dialogue.root_node)
    _calculate_children_global_offset(dialogue.root_node)
    var root_renderer = node_renderers[dialogue.root_node.id]
    var root_offset = root_renderer.offset + Vector2(root_renderer.rect_size.x / 2, -root_renderer.rect_size.y / 2)
    for renderer in node_renderers.values():
        renderer.offset -= root_offset


func _get_children_height(node: DialogueNode) -> int:
    if node.children.empty() or collapsed_nodes.has(node.id):
        return 0
    if not _cached_children_heights.has(node):
        var sum = 0
        for child in node.children:
            sum += _get_height(child)
        _cached_children_heights[node] = sum + (node.children.size() - 1) * vertical_spacing
    return _cached_children_heights[node]


func _get_height(node: DialogueNode) -> int:
    if not node:
        return 0
    if not _cached_node_heights.has(node):
        _cached_node_heights[node] = int(max(node_renderers[node.id].rect_size.y, _get_children_height(node)))
    return _cached_node_heights[node]


func _get_bottom(node: DialogueNode) -> int:
    if not node:
        return 0
    var renderer = node_renderers[node.id]
    var children_height = _get_children_height(node)

    var delta = renderer.rect_size.y
    if children_height > renderer.rect_size.y:
        delta = renderer.rect_size.y / 2 + children_height / 2
    return renderer.offset.y + delta + vertical_spacing


func _shift_offset(node: DialogueNode, shift: Vector2) -> void:
    if not node:
        return
    node_renderers[node.id].offset += shift
#    _shift_children_offset(node, shift)


func _shift_children_offset(node: DialogueNode, shift: Vector2) -> void:
    if collapsed_nodes.has(node.id):
        return
    for child in node.children:
        _shift_offset(child, shift)


func _calculate_children_global_offset(node) -> void:
    if collapsed_nodes.has(node.id):
        return
    for child in node.children:
        _shift_offset(child, node_renderers[node.id].offset)
        _calculate_children_global_offset(child)


func _calculate_children_local_offset(node: DialogueNode) -> void:
    if not node or collapsed_nodes.has(node.id):
        return
    var renderer = node_renderers[node.id]
    var children_height = _get_children_height(node)

    var prev_child = null
    for child in node.children:
        _calculate_children_local_offset(child)

        var y_offset = _calculate_below_node_offset(child, prev_child)
        if not prev_child:
            y_offset -= (children_height - renderer.rect_size.y) / 2
        node_renderers[child.id].offset = Vector2(renderer.rect_size.x + horizontal_spacing, y_offset)
        prev_child = child

#    var cur_height = _get_height(node)
#    var children_height = _get_children_height(node)
#    renderer.offset = Vector2(0, cur_height / 2 - renderer_height / 2)
#    _shift_children_offset(node, Vector2(0, max((renderer_height - children_height) / 2, 0)))


func _calculate_below_node_offset(node: DialogueNode, above_node: DialogueNode) -> int:
    var renderer = node_renderers[node.id]
    var children_height = _get_children_height(node)
    var delta = 0
    if renderer.rect_size.y < children_height:
        delta = children_height / 2 - renderer.rect_size.y / 2
    return _get_bottom(above_node) + delta


func _allocate_node_renderer() -> DialogueNodeRenderer:
    _used_node_renderers += 1

    if _used_node_renderers > _cached_node_renderers.size():
        _cached_node_renderers.resize(_used_node_renderers)
        for i in range(_used_node_renderers - 1, _cached_node_renderers.size()):
            var node_renderer = NODE_RENDERER_SCENE.instance() as DialogueNodeRenderer
            _cached_node_renderers[i] = node_renderer
            add_child(node_renderer)
            node_renderer.connect("dragged", self, "_on_node_dragged", [node_renderer])
            node_renderer.connect("close_request", self, "_on_node_collapsed", [node_renderer])
            _reset_node_renderer(node_renderer)

    var res: DialogueNodeRenderer = _cached_node_renderers[_used_node_renderers - 1]
    res.show()
    res.selected = false

    return res


func _add_node_renderer(node: DialogueNode) -> void:
    var node_renderer = _allocate_node_renderer()
    node_renderers[node.id] = node_renderer
    node_renderer.node = node
    node_renderer.is_collapsed = collapsed_nodes.has(node.id)


func _recursively_add_node_renderers(node: DialogueNode) -> void:
    _used_node_renderers = 0
    var stack := [node]
    while not stack.empty():
        node = stack.pop_back()
        _add_node_renderer(node)
        if collapsed_nodes.has(node.id):
            continue
        for child in node.children:
            stack.push_back(child)


#func _recursively_add_node_renderers(node: DialogueNode) -> void:
#    _add_node_renderer(node)
#    if collapsed_nodes.has(node.id):
#        return
#    for child in node.children:
#        _recursively_add_node_renderers(child)


func _on_node_dragged(from: Vector2, to: Vector2, node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer.visible:
        return
    _session.dialogue_undo_redo.commit_action("Drag Node", self, "_drag_node",
            {"from": from, "to": to, "node_renderer": node_renderer})


func _drag_node(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    # cache parameters
    var dragged_node_renderer: DialogueNodeRenderer = args["node_renderer"]
    var from: Vector2 = args["from"]
    var to: Vector2 = args["to"]

    # ignore dragging of root node
    if dragged_node_renderer.node.parent_id == DialogueNode.DUMMY_ID:
        dragged_node_renderer.offset = from
        return null

    var parent: DialogueNode = dialogue.nodes[dragged_node_renderer.node.parent_id]

    # there was a bug idk
    if from == Vector2.ZERO:
        return null

    # move child node
    var move_up := to.y < from.y
    var up_range := range(parent.children.size())
    var down_range := range(parent.children.size() - 1, -1, -1)
    for i in up_range if move_up else down_range:
        var sibling_node = parent.children[i]
        if sibling_node.id == dragged_node_renderer.node.id:
            break
        var sibling_renderer: DialogueNodeRenderer = node_renderers[sibling_node.id]
        if ((move_up and to.y < sibling_renderer.offset.y + sibling_renderer.rect_size.y * (1 - dragging_percentage)) or
                (not move_up and to.y + dragged_node_renderer.rect_size.y * (1 - dragging_percentage) > sibling_renderer.offset.y)):
            # reference nodes in new dialogue
            parent = dialogue.nodes[parent.id]
            var dragged_node = dialogue.nodes[dragged_node_renderer.node.id]

            parent.children.erase(dragged_node)
            parent.children.insert(i, dragged_node)
            return dialogue

    # ignore dragging if no changes
    dragged_node_renderer.offset = from
    return null


func _on_node_collapsed(node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer or not node_renderer.node:
        return

    if collapsed_nodes.has(node_renderer.node.id):
        collapsed_nodes.erase(node_renderer.node.id)
    else:
        collapsed_nodes[node_renderer.node.id] = true

    update_graph()
    emit_signal("collapsed_nodes_changed")


func _reset_node_renderer(node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer:
        return
    node_renderer.node = null
    node_renderer.selected = false
    node_renderer.offset = CACHED_RENDERER_OFFSET
    node_renderer.hide()
