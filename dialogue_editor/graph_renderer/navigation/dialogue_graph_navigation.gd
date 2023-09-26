tool
extends Node


export(float) var reach_target_time := 0.30

var graph_renderer: DialogueGraphRenderer setget set_graph_renderer

var _prev_target_offsets: Vector2

# node id
var _cursor_position: int setget _set_cursor_position

onready var _focus_tween: Tween = $FocusTween
onready var _label: Label = $Label


func _input(event: InputEvent) -> void:
    if not graph_renderer or not event is InputEventKey or not event.is_pressed():
        return

    if !graph_renderer.has_focus():
        return

    match event.scancode:
        KEY_UP:
            move_cursor_vertically(-1, Input.is_key_pressed(KEY_SHIFT))
        KEY_DOWN:
            move_cursor_vertically(1, Input.is_key_pressed(KEY_SHIFT))
        KEY_LEFT:
            move_cursor_horizontally(-1, Input.is_key_pressed(KEY_SHIFT))
        KEY_RIGHT:
            move_cursor_horizontally(1, Input.is_key_pressed(KEY_SHIFT))
        KEY_KP_ADD:
            if Input.is_key_pressed(KEY_CONTROL):
                zoom_in()
        KEY_KP_SUBTRACT:
            if Input.is_key_pressed(KEY_CONTROL):
                zoom_out()


func set_graph_renderer(new_graph_renderer: DialogueGraphRenderer) -> void:
    if graph_renderer:
        graph_renderer.disconnect("node_selected", self, "_on_node_selected")
        graph_renderer.disconnect("node_unselected", self, "_on_node_unselected")
        graph_renderer.disconnect("finished_updating", self, "_on_graph_renderer_finished_updating")
    graph_renderer = new_graph_renderer
    if graph_renderer:
        graph_renderer.connect("node_selected", self, "_on_node_selected")
        graph_renderer.connect("node_unselected", self, "_on_node_unselected")
        graph_renderer.connect("finished_updating", self, "_on_graph_renderer_finished_updating")


func zoom_in() -> void:
    _set_zoom(graph_renderer.zoom * graph_renderer.zoom_step)


func zoom_out() -> void:
    _set_zoom(graph_renderer.zoom / graph_renderer.zoom_step)


func move_cursor_vertically(direction: int, keep_old_selection: bool) -> void:
    var cur_node: DialogueNode = graph_renderer.dialogue.get_node(_cursor_position)

    if not cur_node:
        select_center_node(keep_old_selection)
        return

    var parent: DialogueNode = graph_renderer.dialogue.get_node(cur_node.parent_id)
    if not parent:
        return

    var new_pos = parent.get_child_position(cur_node) + direction
    new_pos = clamp(new_pos, 0, parent.children.size() - 1)

    if not keep_old_selection:
        graph_renderer.unselect_all()
    graph_renderer.select_node(parent.children[new_pos])

    keep_on_screen([parent.children[new_pos]])


func move_cursor_horizontally(direction: int, keep_old_selection: bool) -> void:
    var cur_node: DialogueNode = graph_renderer.dialogue.get_node(_cursor_position)

    if not cur_node:
        select_center_node(keep_old_selection)
        return

    var new_cursor_pos = _cursor_position

    if direction < 0:
        if cur_node.parent_id != -1:
            new_cursor_pos = cur_node.parent_id
    else:
        if not cur_node.children.empty():
            var middle_child_pos := (cur_node.children.size() - 1) / 2
            new_cursor_pos = cur_node.children[middle_child_pos].id

    if not keep_old_selection:
        graph_renderer.unselect_all()
    graph_renderer.select_node_by_id(new_cursor_pos)

    keep_on_screen([graph_renderer.dialogue.get_node(new_cursor_pos)])


func focus_selected_nodes(with_children: bool = false) -> void:
    var selected_nodes = graph_renderer.dialogue.get_nodes(graph_renderer.get_selected_node_ids())
    if not selected_nodes.empty():
        focus_nodes(selected_nodes, with_children)
    else:
        focus_nodes(graph_renderer.dialogue.nodes.values())


# nodes: Array[DialogueNode]
func focus_nodes(nodes: Array, with_children: bool = false) -> void:
    if with_children:
        # Set[DialogueNode]
        var all_nodes := {}
        for node in nodes:
            if all_nodes.has(node):
                continue
            all_nodes[node] = true
            for child in graph_renderer.dialogue.get_branch(node):
                all_nodes[child] = true
        nodes = all_nodes.keys()


    var result = _get_enclosing_rect(nodes)
    if result is GDScriptFunctionState:
        result = yield(result, "completed")

    var target_rect: Rect2 = result
    var target_zoom := _get_target_zoom(target_rect)
    var target_offset = target_rect.get_center() * target_zoom - graph_renderer.rect_size / 2
    _set_zoom_and_offset(target_zoom, target_offset)


# nodes: Array[DialogueNode]
func keep_on_screen_with_children(nodes: Array) -> void:
    var nodes_with_children := {}
    for node in nodes:
        graph_renderer.dialogue._recursively_collect_children(node, nodes_with_children)
    keep_on_screen(nodes_with_children.keys())


# nodes: Array[DialogueNode]
func keep_on_screen(nodes: Array) -> void:
    var result = _get_enclosing_rect(nodes)
    if result is GDScriptFunctionState:
        result = yield(result, "completed")

    var enclosing_rect: Rect2 = result
    var enclosing_rect_zoomed := enclosing_rect
    var zoom: float = graph_renderer.zoom
    enclosing_rect_zoomed.position *= zoom
    enclosing_rect_zoomed.size *= zoom

    var graph_viewport := Rect2(graph_renderer.scroll_offset, graph_renderer.rect_size)

    if not graph_viewport.encloses(enclosing_rect_zoomed):
        var target_zoom := _get_target_zoom(enclosing_rect, zoom)

        var target_viewport := graph_viewport
        target_viewport.position *= target_zoom / zoom

        var enclosing_rect_target_zoomed := enclosing_rect
        enclosing_rect_target_zoomed.position *= target_zoom
        enclosing_rect_target_zoomed.size *= target_zoom

        # determine which corner to move
        var viewport_corners := _get_corners(target_viewport)
        var rect_corners := _get_corners(enclosing_rect_target_zoomed)

        var min_delta := rect_corners[0] - viewport_corners[0]
        for i in range(1, 4):
            var delta := rect_corners[i] - viewport_corners[i]
            if delta.length() < min_delta.length():
                min_delta = delta

        if _encloses_by_x(target_viewport, enclosing_rect_target_zoomed):
            min_delta.x = 0
        if _encloses_by_y(target_viewport, enclosing_rect_target_zoomed):
            min_delta.y = 0

        var target_offset := target_viewport.position + min_delta

        _set_zoom_and_offset(target_zoom, target_offset)


func select_center_node(keep_old_selection: bool) -> DialogueNode:
    var viewport_center_offset = _get_viewport_center_offset()
    var closest_node: DialogueNode = null
    var min_distance: float

    for node_renderer in graph_renderer.node_renderers.values():
        var distance = (node_renderer.offset - viewport_center_offset).length()
        if not closest_node or distance < min_distance:
            min_distance = distance
            closest_node = node_renderer.node

    if closest_node:
        if not keep_old_selection:
            graph_renderer.unselect_all()
        graph_renderer.select_node(closest_node)
        keep_on_screen([closest_node])

    return closest_node


func _get_viewport_center_offset() -> Vector2:
    return (graph_renderer.scroll_offset + graph_renderer.rect_size * 0.5) / graph_renderer.zoom


func _set_zoom(target_zoom: float) -> void:
    target_zoom = clamp(target_zoom, graph_renderer.zoom_min, graph_renderer.zoom_max)
    var target_scroll_offset = _get_viewport_center_offset() * target_zoom - graph_renderer.rect_size * 0.5
    _set_zoom_and_offset(target_zoom, target_scroll_offset)


func _set_zoom_and_offset(target_zoom: float, target_offset: Vector2) -> void:
    # set zoom first for target offset to be reached correctly (it depends on zoom)
    _focus_tween.interpolate_property(graph_renderer, "zoom",
            graph_renderer.zoom, target_zoom, reach_target_time, Tween.TRANS_SINE)
    _focus_tween.interpolate_property(graph_renderer, "scroll_offset",
            graph_renderer.scroll_offset, target_offset, reach_target_time, Tween.TRANS_SINE)
    _focus_tween.start()


# nodes: Array[DialogueNode]
func _uncollapse_parent_nodes(nodes: Array) -> void:
    # Array[DialogueNode]
    var nodes_to_uncollapse := []

    for node in nodes:
        var cur_node: DialogueNode = graph_renderer.dialogue.get_node(node.parent_id)
        while cur_node:
            if graph_renderer.collapsed_node_ids.has(cur_node.id):
                nodes_to_uncollapse.append(cur_node)
            cur_node = graph_renderer.dialogue.get_node(cur_node.parent_id)

    if not nodes_to_uncollapse.empty():
        graph_renderer.uncollapse_nodes(nodes_to_uncollapse)
        yield(graph_renderer, "finished_updating")


# nodes: Array[DialogueNode]
func _get_enclosing_rect(nodes: Array) -> Rect2:
    var result = _uncollapse_parent_nodes(nodes)
    if result is GDScriptFunctionState:
        yield(result, "completed")

    var node_renderers := graph_renderer.get_node_renderers(nodes)

    var enclosing_rect: Rect2
    for renderer in node_renderers:
        if not enclosing_rect:
            enclosing_rect = renderer.get_graph_rect()
        else:
            enclosing_rect = enclosing_rect.merge(renderer.get_graph_rect())

    return enclosing_rect


func _get_target_zoom(target_rect: Rect2, max_zoom := 1.0) -> float:
    var zoom_xy = graph_renderer.rect_size / target_rect.size
    return min(min(zoom_xy.x, zoom_xy.y), max_zoom)


func _encloses_by_x(a: Rect2, b: Rect2) -> bool:
    return a.position.x <= b.position.x and a.position.x + a.size.x >= b.position.x + b.size.x


func _encloses_by_y(a: Rect2, b: Rect2) -> bool:
    return a.position.y <= b.position.y and a.position.y + a.size.y >= b.position.y + b.size.y


func _get_corners(rect: Rect2) -> PoolVector2Array:
    var output := PoolVector2Array()
    output.resize(4)

    var offset := [Vector2.ZERO, Vector2(rect.size.x, 0), rect.size, Vector2(0, rect.size.y)]
    for i in range(4):
        output[i] = rect.position + offset[i]

    return output


func _on_node_selected(node_renderer: DialogueNodeRenderer) -> void:
    _set_cursor_position(node_renderer.node.id)


func _on_node_unselected(node_renderer: DialogueNodeRenderer) -> void:
    if not node_renderer or node_renderer.node.id == _cursor_position:
        _set_cursor_position(-1)


func _set_cursor_position(new_cursor_position: int) -> void:
    if graph_renderer.node_renderers.has(_cursor_position):
        graph_renderer.node_renderers[_cursor_position].overlay = GraphNode.OVERLAY_DISABLED
    _cursor_position = new_cursor_position
    if graph_renderer.node_renderers.has(_cursor_position):
        graph_renderer.node_renderers[_cursor_position].overlay = GraphNode.OVERLAY_BREAKPOINT

    _label.text = "CURSOR POS: %d" % _cursor_position


func _on_graph_renderer_finished_updating() -> void:
    if graph_renderer.node_renderers.has(_cursor_position):
        graph_renderer.node_renderers[_cursor_position].overlay = GraphNode.OVERLAY_BREAKPOINT
