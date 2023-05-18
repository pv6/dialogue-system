tool
extends Node


export(float) var reach_target_time := 0.30

var graph_renderer: DialogueGraphRenderer

var _prev_target_offsets: Vector2

onready var _focus_tween: Tween = $FocusTween


func _unhandled_key_input(event: InputEventKey) -> void:
    if not graph_renderer:
        return

    # TODO: handle though menu buttons
    if not event.is_pressed():
        match event.scancode:
            KEY_F:
                focus_selected_nodes(Input.is_key_pressed(KEY_SHIFT))
            KEY_UP:
                select_vertical_neighbour_nodes(-1, Input.is_key_pressed(KEY_SHIFT))
            KEY_DOWN:
                select_vertical_neighbour_nodes(1, Input.is_key_pressed(KEY_SHIFT))
            KEY_LEFT:
                select_horizontal_neighbour_nodes(-1, Input.is_key_pressed(KEY_SHIFT))
            KEY_RIGHT:
                select_horizontal_neighbour_nodes(1, Input.is_key_pressed(KEY_SHIFT))


func select_vertical_neighbour_nodes(shift: int, keep_old_selection: bool) -> void:
    var dialogue: Dialogue = graph_renderer.dialogue
    # Array[DialogueNode]
    var selected_nodes: Array = dialogue.get_nodes(graph_renderer.get_selected_node_ids())

    if selected_nodes.empty():
        select_center_node()
        return

    selected_nodes.sort_custom(Dialogue.NodeVerticalSorter.new(dialogue.nodes, shift > 0), "less_than")

    for node in selected_nodes:
        var parent := dialogue.get_node(node.parent_id)
        if not parent:
            continue
        var node_pos := parent.get_child_position(node)
        var new_selection_pos := node_pos + shift
        if new_selection_pos < 0 or new_selection_pos >= parent.children.size():
            continue
        var new_selected_node: DialogueNode = parent.children[new_selection_pos]
        _handle_selection(node, new_selected_node, keep_old_selection)

    keep_on_screen(dialogue.get_nodes(graph_renderer.get_selected_node_ids()))


func select_horizontal_neighbour_nodes(shift: int, keep_old_selection: bool) -> void:
    var dialogue: Dialogue = graph_renderer.dialogue
    # Array[DialogueNode]
    var selected_nodes: Array = dialogue.get_nodes(graph_renderer.get_selected_node_ids())

    if selected_nodes.empty():
        select_center_node()
        return

    selected_nodes.sort_custom(Dialogue.NodeHorizontalSorter.new(dialogue.nodes, shift > 0), "less_than")

    for node in selected_nodes:
        var new_selected_node: DialogueNode = node
        for i in range(abs(shift)):
            if shift < 0:
                if new_selected_node.parent_id == DialogueNode.DUMMY_ID:
                    break
                new_selected_node = dialogue.nodes[new_selected_node.parent_id]
            else:
                if new_selected_node.children.empty():
                    break
                var middle_pos := (new_selected_node.children.size() - 1) / 2
                new_selected_node = new_selected_node.children[middle_pos]

        _handle_selection(node, new_selected_node, keep_old_selection)

    keep_on_screen(dialogue.get_nodes(graph_renderer.get_selected_node_ids()))


func focus_selected_nodes(with_children: bool = false) -> void:
    focus_nodes(graph_renderer.dialogue.get_nodes(graph_renderer.get_selected_node_ids()), with_children)


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

    var target_rect := _get_enclosing_rect(nodes)
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
    var enclosing_rect := _get_enclosing_rect(nodes)
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


func select_center_node() -> DialogueNode:
    var viewport_center_offset = (graph_renderer.scroll_offset + graph_renderer.rect_size * 0.5) / graph_renderer.zoom
    var closest_node: DialogueNode = null
    var min_distance: float

    for node_renderer in graph_renderer.node_renderers.values():
        var distance = (node_renderer.offset - viewport_center_offset).length()
        if not closest_node or distance < min_distance:
            min_distance = distance
            closest_node = node_renderer.node

    if closest_node:
        graph_renderer.select_node(closest_node)
        keep_on_screen([closest_node])

    return closest_node


func _set_zoom_and_offset(target_zoom: float, target_offset: Vector2) -> void:
    # set zoom first for target offset to be reached correctly (it depends on zoom)
    _focus_tween.interpolate_property(graph_renderer, "zoom",
            graph_renderer.zoom, target_zoom, reach_target_time, Tween.TRANS_SINE)
    _focus_tween.interpolate_property(graph_renderer, "scroll_offset",
            graph_renderer.scroll_offset, target_offset, reach_target_time, Tween.TRANS_SINE)
    _focus_tween.start()


# nodes: Array[DialogueNode]
func _get_enclosing_rect(nodes: Array) -> Rect2:
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


func _handle_selection(old_selected_node: DialogueNode, new_selected_node: DialogueNode, keep_old_selection: bool) -> void:
    if graph_renderer.is_node_selected(new_selected_node):
        return
    if not keep_old_selection:
        graph_renderer.unselect_node(old_selected_node)
    graph_renderer.select_node(new_selected_node)
#    if keep_old_selection:
#        if graph_renderer.is_node_selected(new_selected_node):
#            graph_renderer.unselect_node(new_selected_node)
#        else:
#            graph_renderer.select_node(new_selected_node)
#    else:
#        if graph_renderer.is_node_selected(new_selected_node):
#            return
#        graph_renderer.unselect_node(old_selected_node)
#        graph_renderer.select_node(new_selected_node)
