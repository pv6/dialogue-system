tool
class_name DialogueGraphRenderer
extends GraphEdit


signal collapsed_nodes_changed()

const NODE_RENDERER_SCENE := preload("../node_renderer/dialogue_node_renderer.tscn")

export(int) var vertical_spacing := 30
export(int) var horizontal_spacing := 30
export(float) var dragging_percentage := 0.69

export(Resource) var dialogue: Resource setget set_dialogue

export(Array) var selected_node_ids: Array setget set_selected_node_ids, get_selected_node_ids

# node id -> renderer
var node_renderers: Dictionary

var collapsed_nodes: Dictionary

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


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


func update_graph() -> void:
    # save selected node ids (node references get deprecated on dialogue cloning)
    var selected := self.selected_node_ids

    # disconnect child nodes
    for node_renderer_a in node_renderers.values():
        for node_renderer_b in node_renderers.values():
            disconnect_node(node_renderer_a.name, 0, node_renderer_b.name, 0)

    # remove old renderers
    for renderer in node_renderers.values():
        renderer.node = null
        remove_child(renderer)
        renderer.disconnect("dragged", self, "_on_node_dragged")
        renderer.disconnect("close_request", self, "_on_node_collapsed")
        renderer.queue_free()
    node_renderers.clear()

    if not dialogue:
        return
    assert(dialogue.root_node)

    # create node renderers
    _recursively_add_node_renderers(dialogue.root_node)

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
            
    _calculate_node_position(dialogue.root_node, Vector2(0, 0))
    var root_renderer = node_renderers[dialogue.root_node.id]
    var root_offset = root_renderer.offset + Vector2(0, root_renderer.rect_size.y / 2)
    for renderer in node_renderers.values():
        renderer.offset -= root_offset


func _get_children_height(node: DialogueNode) -> int:
    if node.children.empty() or collapsed_nodes.has(node.id):
        return 0
    var sum = 0
    for child in node.children:
        sum += _get_height(child)
    return sum + (node.children.size() - 1) * vertical_spacing


func _get_height(node: DialogueNode) -> int:
    if not node:
        return 0
    return int(max(node_renderers[node.id].rect_size.y, _get_children_height(node)))


func _get_bottom(node: DialogueNode) -> int:
    if not node:
        return 0
    var renderer = node_renderers[node.id]
    return renderer.offset.y + renderer.rect_size.y / 2 + _get_height(node) / 2 + vertical_spacing


func _shift_offset(node: DialogueNode, shift: Vector2) -> void:
    if not node:
        return
    node_renderers[node.id].offset += shift
    _shift_children_offset(node, shift)


func _shift_children_offset(node: DialogueNode, shift: Vector2) -> void:
    if collapsed_nodes.has(node.id):
        return
    for child in node.children:
        _shift_offset(child, shift)


func _calculate_node_position(node: DialogueNode, start_pos: Vector2) -> void:
    if not node:
        return
    var prev_child = null
    if not collapsed_nodes.has(node.id):
        for child in node.children:
            _calculate_node_position(child, Vector2(node_renderers[node.id].rect_size.x + horizontal_spacing, _get_bottom(prev_child)))
            prev_child = child
    var cur_height = _get_height(node)
    var renderer = node_renderers[node.id]
    var renderer_height = renderer.rect_size.y
    var children_height = _get_children_height(node)
    renderer.offset = Vector2(0, cur_height / 2 - renderer_height / 2)
    _shift_offset(node, Vector2(start_pos.x, start_pos.y))
    _shift_children_offset(node, Vector2(0, max((renderer_height - children_height) / 2, 0)))


func _add_node_renderer(node: DialogueNode) -> void:
    var node_renderer := NODE_RENDERER_SCENE.instance() as DialogueNodeRenderer
    node_renderers[node.id] = node_renderer
    node_renderer.node = node
    node_renderer.is_collapsed = collapsed_nodes.has(node.id)
    node_renderer.connect("dragged", self, "_on_node_dragged", [node_renderer])
    node_renderer.connect("close_request", self, "_on_node_collapsed", [node_renderer.node.id])
    add_child(node_renderer)


func _recursively_add_node_renderers(node: DialogueNode) -> void:
    _add_node_renderer(node)
    if collapsed_nodes.has(node.id):
        return
    for child in node.children:
        _recursively_add_node_renderers(child)


func _on_node_dragged(from: Vector2, to: Vector2, node_renderer: DialogueNodeRenderer) -> void:
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


func _on_node_collapsed(node_id: int) -> void:
    if collapsed_nodes.has(node_id):
        collapsed_nodes.erase(node_id)
    else:
        collapsed_nodes[node_id] = true
    update_graph()
    emit_signal("collapsed_nodes_changed")
