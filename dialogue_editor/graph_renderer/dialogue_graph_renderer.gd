tool
class_name DialogueGraphRenderer
extends GraphEdit


const NODE_RENDERER_SCENE := preload("../node_renderer/dialogue_node_renderer.tscn")

export(int) var vertical_spacing := 30
export(int) var horizontal_spacing := 30
export(float) var dragging_percentage := 0.69

export(Resource) var dialogue: Resource setget set_dialogue

export(Array) var selected_node_ids: Array setget set_selected_node_ids, get_selected_node_ids

# node id -> renderer
var node_renderers: Dictionary

var _dragged_node_renderer: DialogueNodeRenderer
var _from: Vector2
var _to: Vector2

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


class NodeDepth:
    var node: DialogueNode
    var depth: int
    var prev_node: DialogueNode
    var pos: Vector2

    func _init(node: DialogueNode, depth: int, prev_node: DialogueNode) -> void:
        self.node = node
        self.depth = depth
        self.prev_node = prev_node


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
        renderer.queue_free()
    node_renderers.clear()

    if not dialogue:
        return
    assert(dialogue.root_node)

    # create node renderers
    for node in dialogue.nodes.values():
        _add_node_renderer(node)

    # restore selected nodes
    for id in selected:
        if dialogue.nodes.has(id):
            node_renderers[id].selected = true

    # connect child nodes
    for node_renderer in node_renderers.values():
        for child in node_renderer.node.children:
            connect_node(node_renderer.name, 0, node_renderers[child.id].name, 0)

    var columns := []

    var visited_nodes := {}
    var stack := [NodeDepth.new(dialogue.root_node, 0, null)]

    # calculate node columns
    while not stack.empty():
        var cur := stack[-1] as NodeDepth
        assert(cur)
        assert(not visited_nodes.has(cur.node))
        stack.pop_back()

        # add new column if needed
        if cur.depth >= columns.size():
            columns.push_back([])
            var cur_column := columns[cur.depth] as Array
            # pad new column with empty nodes so that last column always largest
            # we're doing it depth first, so "upper" branches have already stopped
            for i in range(columns[cur.depth - 1].size() - 1):
                cur_column.push_back(NodeDepth.new(null, cur.depth, columns[cur.depth - 1][i].prev_node))

        # save node information into current column
        columns[cur.depth].push_back(cur)

        # if null node, propagate towards last column
        if not cur.node:
            if cur.depth < columns.size() - 1:
                stack.push_back(NodeDepth.new(null, cur.depth + 1, cur.prev_node))
        else:
            visited_nodes[cur.node] = true
            # add null node as child if no children
            if cur.node.children.empty():
                stack.push_back(NodeDepth.new(null, cur.depth + 1, cur.node))
            else:
                # add children nodes
                for i in range(cur.node.children.size() - 1, -1, -1):
                    var next_node = cur.node.children[i]
                    if not visited_nodes.has(next_node):
                        stack.push_back(NodeDepth.new(next_node, cur.depth + 1, cur.node))

    # calculate positions
    var node_size := (node_renderers.values()[0] as DialogueNodeRenderer).rect_size
    var max_column_size := columns[-2].size() as int
    var pixel_height := node_size.y * (max_column_size - 1) + vertical_spacing * (max_column_size - 1)

    # starting with last column - 1 (last column is all null nodes)
    for i in range(columns.size() - 2, -1, -1):
        for j in range(columns[i].size()):
            var cur = columns[i][j]
            cur.pos.x = node_size.x * i + horizontal_spacing * i
            if i == columns.size() - 2:
                if max_column_size > 1:
                    cur.pos.y = j * pixel_height / (max_column_size - 1)
                else:
                    cur.pos.y = 0
            else:
                var sum_pos_y := 0.0
                var count := 0
                for nd in columns[i + 1]:
                    if (cur.node and nd.prev_node == cur.node) or (not cur.node and nd.prev_node == cur.prev_node):
                        sum_pos_y += nd.pos.y
                        count += 1
                assert(count > 0)
                cur.pos.y = sum_pos_y / count

    # subtract root node position to move root to (0, 0)
    var root_pos = columns[0][0].pos
    for col in columns:
        for nd in col:
            if nd.node:
                node_renderers[nd.node.id].offset = nd.pos - root_pos


func _add_node_renderer(node: DialogueNode) -> void:
    var node_renderer := NODE_RENDERER_SCENE.instance() as DialogueNodeRenderer
    node_renderers[node.id] = node_renderer
    node_renderer.node = node
    node_renderer.connect("dragged", self, "_on_node_dragged", [node_renderer])
    add_child(node_renderer)


func _on_node_dragged(from: Vector2, to: Vector2, node_renderer: DialogueNodeRenderer) -> void:
    _dragged_node_renderer = node_renderer
    _from = from
    _to = to
    _session.dialogue_undo_redo.commit_action("Drag Node", self, "_drag_node")


func _drag_node(dialogue: Dialogue) -> Dialogue:
    # ignore dragging of root node
    if _dragged_node_renderer.node.parent_id == DialogueNode.DUMMY_ID:
        _dragged_node_renderer.offset = _from
        return null

    var parent: DialogueNode = dialogue.nodes[_dragged_node_renderer.node.parent_id]

    # there was a bug idk
    if _from == Vector2.ZERO:
        return null

    # move child node
    var move_up := _to.y < _from.y
    var up_range := range(parent.children.size())
    var down_range := range(parent.children.size() - 1, -1, -1)
    for i in up_range if move_up else down_range:
        var sibling_node = parent.children[i]
        if sibling_node.id == _dragged_node_renderer.node.id:
            break
        var sibling_renderer: DialogueNodeRenderer = node_renderers[sibling_node.id]
        if ((move_up and _to.y < sibling_renderer.offset.y + sibling_renderer.rect_size.y * (1 - dragging_percentage)) or
                (not move_up and _to.y + _dragged_node_renderer.rect_size.y * (1 - dragging_percentage) > sibling_renderer.offset.y)):
            # reference nodes in new dialogue
            parent = dialogue.nodes[parent.id]
            var dragged_node = dialogue.nodes[_dragged_node_renderer.node.id]

            parent.children.erase(dragged_node)
            parent.children.insert(i, dragged_node)
            return dialogue

    # ignore dragging if no changes
    _dragged_node_renderer.offset = _from
    return null
