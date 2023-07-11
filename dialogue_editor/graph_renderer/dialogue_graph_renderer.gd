tool
class_name DialogueGraphRenderer
extends GraphEdit


signal collapsed_nodes_changed()
signal finished_updating()

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
var collapsed_node_ids: Dictionary

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

var _cached_node_heights := {}
var _cached_children_heights := {}

# Dictionary[Script, Array[DialogueNodeRenderer]]
var _cached_node_renderers: Dictionary
# Dictionary[Script, int]
var _used_node_renderers: Dictionary

var _is_ready := false

onready var _focus_rect: Control = $FocusRect


func _init() -> void:
    collapsed_node_ids = {}
    node_renderers = {}


func _draw():
    if has_focus():
         _focus_rect.show()
    else:
         _focus_rect.hide()


func set_dialogue(new_dialogue: Dialogue) -> void:
    if dialogue:
        if dialogue.is_connected("nodes_changed", self, "update_graph"):
            dialogue.disconnect("nodes_changed", self, "update_graph")
    dialogue = new_dialogue
    if dialogue:
        if not dialogue.is_connected("nodes_changed", self, "update_graph"):
            dialogue.connect("nodes_changed", self, "update_graph")
    update_graph()


func get_node_renderer_by_id(node_id: int) -> DialogueNodeRenderer:
    if not node_renderers.has(node_id):
        return null
    return node_renderers[node_id]


func get_node_renderer(node: DialogueNode) -> DialogueNodeRenderer:
    if not node:
        return null
    return get_node_renderer_by_id(node.id)


# nodes: Array[DialogueNode]
func get_node_renderers(nodes: Array) -> Array:
    var output := []
    for node in nodes:
        output.push_back(node_renderers[node.id])
    return output


func get_selected_node_ids() -> Array:
    var out := []
    for renderer in node_renderers.values():
        if renderer.selected:
            out.push_back(renderer.node.id)
    return out


func set_selected_node_ids(new_ids: Array) -> void:
    var old_ids = self.selected_node_ids
    for id in old_ids:
        unselect_node_by_id(id)
    for id in new_ids:
        select_node_by_id(id)


func is_node_selected_by_id(node_id: int) -> bool:
    if not node_renderers.has(node_id):
        return false
    return node_renderers[node_id].selected


func is_node_selected(node: DialogueNode) -> bool:
    return is_node_selected_by_id(node.id)


func select_node(node: DialogueNode) -> void:
    select_node_by_id(node.id)


func unselect_node(node: DialogueNode) -> void:
    unselect_node_by_id(node.id)


func select_node_by_id(node_id: int) -> void:
    assert(node_renderers.has(node_id))
    var renderer: DialogueNodeRenderer = node_renderers[node_id]
    renderer.selected = true
    emit_signal("node_selected", renderer)


func unselect_node_by_id(node_id: int) -> void:
    assert(node_renderers.has(node_id))
    var renderer: DialogueNodeRenderer = node_renderers[node_id]
    renderer.selected = false
    emit_signal("node_unselected", renderer)


func unselect_all() -> void:
    set_selected_node_ids([])


func is_collapsed(node: DialogueNode) -> bool:
    return collapsed_node_ids.has(node.id)


func collapse_node(node: DialogueNode) -> void:
    if is_collapsed(node):
        return

    _collapse_node_internal(node)

    update_graph()
    emit_signal("collapsed_nodes_changed")


func uncollapse_node(node: DialogueNode) -> void:
    if not collapsed_node_ids.has(node.id):
        return

    collapsed_node_ids.erase(node.id)
    update_graph()
    emit_signal("collapsed_nodes_changed")


# nodes: Array[DialogueNode]
func collapse_nodes(nodes: Array) -> void:
    var made_changes := false

    for node in nodes:
        if is_collapsed(node):
            continue
        _collapse_node_internal(node)
        made_changes = true

    if made_changes:
        update_graph()
        emit_signal("collapsed_nodes_changed")


# nodes: Array[DialogueNode]
func uncollapse_nodes(nodes: Array) -> void:
    var made_changes := false

    for node in nodes:
        if not is_collapsed(node):
            continue
        collapsed_node_ids.erase(node.id)
        made_changes = true

    if made_changes:
        update_graph()
        emit_signal("collapsed_nodes_changed")


func is_ready() -> bool:
    return _is_ready


func update_node_sizes() -> void:
    for renderer in node_renderers.values():
        renderer.contents.update_size()
        renderer.rect_size = _session.settings.node_min_size
    call_deferred("_update_renderer_offsets")


func update_graph() -> void:
    _is_ready = false

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
    var old_used_renderers := {}
    for node_type in _cached_node_renderers.keys():
        old_used_renderers[node_type] = _used_node_renderers[node_type]

    _recursively_add_node_renderers(dialogue.root_node)

    for node_type in _cached_node_renderers.keys():
        # Array[DialogueNodeRenderer]
        var cached_renderers: Array = _cached_node_renderers[node_type]

        if _session.settings.cache_unused_node_renderers:
            if not old_used_renderers.has(node_type):
                old_used_renderers[node_type] = 0
            for i in range(_used_node_renderers[node_type], old_used_renderers[node_type]):
                _reset_node_renderer(cached_renderers[i])
        else:
            var cur_used_renderers: int = _used_node_renderers[node_type]
            for i in range(cur_used_renderers, cached_renderers.size()):
                cached_renderers[i].queue_free()
            cached_renderers.resize(cur_used_renderers)

    # restore selected nodes
    for id in selected:
        if dialogue.nodes.has(id) and node_renderers.has(id):
            node_renderers[id].selected = true

    # connect child nodes
    for node_renderer in node_renderers.values():
        if collapsed_node_ids.has(node_renderer.node.id):
            # uncollapse nodes that have no children
            if node_renderer.node.children.empty():
                collapsed_node_ids.erase(node_renderer.node.id)
                node_renderer.is_collapsed = false
            else:
                continue
        for child in node_renderer.node.children:
            connect_node(node_renderer.name, 0, node_renderers[child.id].name, 0)

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

    _is_ready = true
    emit_signal("finished_updating")


func _get_children_height(node: DialogueNode) -> int:
    if node.children.empty() or collapsed_node_ids.has(node.id):
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
    if collapsed_node_ids.has(node.id):
        return
    for child in node.children:
        _shift_offset(child, shift)


func _calculate_children_global_offset(node) -> void:
    if collapsed_node_ids.has(node.id):
        return
    for child in node.children:
        _shift_offset(child, node_renderers[node.id].offset)
        _calculate_children_global_offset(child)


func _calculate_children_local_offset(node: DialogueNode) -> void:
    if not node or collapsed_node_ids.has(node.id):
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


func _allocate_node_renderer(node: DialogueNode) -> DialogueNodeRenderer:
    var type: Script = node.get_script()

    var cached_renderers: Array
    if not _cached_node_renderers.has(type):
        _cached_node_renderers[type] = []
        _used_node_renderers[type] = 0

    cached_renderers = _cached_node_renderers[type]

    _used_node_renderers[type] += 1
    var used_renderers: int = _used_node_renderers[type]

    if used_renderers > cached_renderers.size():
        cached_renderers.resize(used_renderers)
        for i in range(used_renderers - 1, cached_renderers.size()):
            var node_renderer = NODE_RENDERER_SCENE.instance() as DialogueNodeRenderer
            cached_renderers[i] = node_renderer
            add_child(node_renderer)
            node_renderer.connect("dragged", self, "_on_node_dragged", [node_renderer])
            node_renderer.connect("close_request", self, "_on_node_collapsed", [node_renderer])
            _reset_node_renderer(node_renderer)

    var res: DialogueNodeRenderer = cached_renderers[used_renderers - 1]
    res.show()
    res.selected = false

    return res


func _add_node_renderer(node: DialogueNode) -> void:
    var node_renderer = _allocate_node_renderer(node)
    node_renderers[node.id] = node_renderer
    node_renderer.node = node
    node_renderer.is_collapsed = collapsed_node_ids.has(node.id)


func _recursively_add_node_renderers(node: DialogueNode) -> void:
    for type in _used_node_renderers:
        _used_node_renderers[type] = 0

    var stack := [node]
    while not stack.empty():
        node = stack.pop_back()
        _add_node_renderer(node)
        if collapsed_node_ids.has(node.id):
            continue
        for child in node.children:
            stack.push_back(child)


#func _recursively_add_node_renderers(node: DialogueNode) -> void:
#    _add_node_renderer(node)
#    if collapsed_node_ids.has(node.id):
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
    var to: Vector2 = args["to"] + get_local_mouse_position() - dragged_node_renderer.rect_position

    # ignore dragging of root node
    if dragged_node_renderer.node is RootDialogueNode:
        dragged_node_renderer.offset = from
        return null

    var parent: DialogueNode = dialogue.nodes[dragged_node_renderer.node.parent_id]

    # there was a bug idk
    if from == Vector2.ZERO:
        return null

    var dragged_node: DialogueNode = dialogue.nodes[dragged_node_renderer.node.id]

    # see if dragged onto another non-sibling node
    for node_renderer in node_renderers.values():
        # skip siblings
        if node_renderer.node.parent_id == dragged_node_renderer.node.parent_id:
            continue

        var ul: Vector2 = node_renderer.offset
        var lr: Vector2 = ul + node_renderer.rect_size

        if to.x >= ul.x and to.y >= ul.y and to.x <= lr.x and to.y <= lr.y:
            var dragged_onto_node: DialogueNode = dialogue.nodes[node_renderer.node.id]

            if dialogue.drag_onto_node(dragged_node, dragged_onto_node):
                return dialogue

            # ignore dragging if no changes
            dragged_node_renderer.offset = from
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

            parent.children.erase(dragged_node)
            parent.children.insert(i, dragged_node)
            return dialogue

    # ignore dragging if no changes
    dragged_node_renderer.offset = from
    return null


func _on_node_collapsed(node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer or not node_renderer.node:
        return

    if collapsed_node_ids.has(node_renderer.node.id):
        uncollapse_node(node_renderer.node)
    else:
        collapse_node(node_renderer.node)


func _reset_node_renderer(node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer:
        return
    node_renderer.node = null
    node_renderer.selected = false
    node_renderer.offset = CACHED_RENDERER_OFFSET
    node_renderer.hide()


func _collapse_node_internal(node: DialogueNode) -> void:
    collapsed_node_ids[node.id] = true

    for child_node in dialogue.get_branch(node):
        if child_node == node:
            continue
        if is_node_selected(child_node):
            unselect_node(child_node)
