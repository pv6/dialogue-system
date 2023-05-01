tool
extends "res://addons/dialogue_system/dialogue_editor/tabs_widget/tab.gd"


const DialogueGraphRendererNavigation := preload("res://addons/dialogue_system/dialogue_editor/graph_renderer/navigation/dialogue_graph_navigation.gd")

const COPY_NODES_STRING_HEADER := "copy ids:"
const CUT_NODES_STRING_HEADER := "cut ids:"

var need_to_redraw_graph := true
var working_dialogue_manager := WorkingResourceManager.new("Dialogue")

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

var _look_at_nodes := []

onready var graph_renderer: DialogueGraphRenderer = $DialogueGraphRenderer
onready var graph_renderer_navigation: DialogueGraphRendererNavigation = $DialogueGraphNavigation
onready var action_condition_widget: ActionConditionWidget = $ActionConditionWidget


func _init() -> void:
    working_dialogue_manager.connect("file_changed", self, "_on_working_dialogue_manager_file_changed")
    working_dialogue_manager.connect("has_unsaved_changes_changed", self, "_on_working_dialogue_manager_has_unsaved_changes_changed")
    working_dialogue_manager.connect("resource_changed", self, "_on_working_dialogue_changed")


func _ready():
    graph_renderer_navigation.graph_renderer = graph_renderer


func _process(delta) -> void:
    if need_to_redraw_graph and graph_renderer:
        graph_renderer.update_graph()
        need_to_redraw_graph = false
    if not _look_at_nodes.empty() and graph_renderer and graph_renderer.is_ready() and graph_renderer_navigation:
        graph_renderer_navigation.keep_on_screen(_look_at_nodes)
        _look_at_nodes.clear()


func get_title() -> String:
    if working_dialogue_manager.save_path == "":
        return "[unsaved]"
    else:
        var path = working_dialogue_manager.save_path
        return path.get_file().trim_suffix("." + path.get_extension())


func get_save_path() -> String:
    return working_dialogue_manager.save_path


func undo() -> void:
    working_dialogue_manager.undo()


func redo() -> void:
    working_dialogue_manager.redo()


func new_dialogue() -> void:
    print("New Dialogue")
    working_dialogue_manager.new_file()
    graph_renderer.collapsed_nodes.clear()
    graph_renderer.unselect_all()


func open_dialogue(file_path: String) -> void:
    print("Open Dialogue '%s'" % file_path)
    working_dialogue_manager.open(file_path)
    graph_renderer.collapsed_nodes.clear()
    graph_renderer.unselect_all()


func save_dialogue() -> void:
    var result = _commit_text_changes()
    if result is GDScriptFunctionState:
        yield(result, "completed")

    print("Save Dialogue")
    _set_dialogue_editor_version()
    working_dialogue_manager.save()


func save_dialogue_as(file_path: String) -> void:
    var result = _commit_text_changes()
    if result is GDScriptFunctionState:
        yield(result, "completed")

    print("Save Dialogue As '%s'" % file_path)
    _set_dialogue_editor_version()
    working_dialogue_manager.save_as(file_path)


func unselect_all() -> void:
    graph_renderer.unselect_all()


func apply_settings() -> void:
    working_dialogue_manager.autosave = _session.settings.autosave
    need_to_redraw_graph = true


func copy_selected_nodes() -> void:
    _copy_selected_node_ids_to_clipboard(COPY_NODES_STRING_HEADER)


func cut_selected_nodes() -> void:
    _copy_selected_node_ids_to_clipboard(CUT_NODES_STRING_HEADER)


func shallow_duplicate_selected_nodes() -> void:
    working_dialogue_manager.commit_action("Shallow Duplicate Selected Nodes", self, "_shallow_duplicate_nodes")


func deep_duplicate_selected_nodes() -> void:
    working_dialogue_manager.commit_action("Deep Duplicate Selected Nodes", self, "_deep_duplicate_nodes")


func move_selected_nodes_up() -> void:
    working_dialogue_manager.commit_action("Move Selected Nodes Up", self, "_move_selected_nodes_vertically", {"shift": -1})


func move_selected_nodes_down() -> void:
    working_dialogue_manager.commit_action("Move Selected Nodes Down", self, "_move_selected_nodes_vertically", {"shift": 1})


func paste_nodes() -> void:
    working_dialogue_manager.commit_action("Paste Nodes", self, "_paste_nodes", {"with_children": false, "as_parent": false})


func paste_cut_nodes_with_children() -> void:
    working_dialogue_manager.commit_action("Paste Cut Nodes With Children", self, "_paste_nodes", {"with_children": true, "as_parent": false})


func paste_cut_node_as_parent() -> void:
    working_dialogue_manager.commit_action("Paste Cut Node As Parent", self, "_paste_nodes", {"with_children": false, "as_parent": true})


func paste_cut_node_with_children_as_parent() -> void:
    working_dialogue_manager.commit_action("Paste Cut Node With Children As Parent", self, "_paste_nodes", {"with_children": true, "as_parent": true})


func insert_parent_hear_node() -> void:
    working_dialogue_manager.commit_action("Insert Parent Hear Node", self, "_insert_parent_hear_node")


func insert_parent_say_node() -> void:
    working_dialogue_manager.commit_action("Insert Parent Say Node", self, "_insert_parent_say_node")


func insert_child_hear_node() -> void:
    working_dialogue_manager.commit_action("Insert Child Hear Node", self, "_insert_child_hear_node")


func insert_child_say_node() -> void:
    working_dialogue_manager.commit_action("Insert Child Say Node", self, "_insert_child_say_node")


func deep_delete_selected_nodes() -> void:
    working_dialogue_manager.commit_action("Deep Delete Selected Nodes", self, "_deep_delete_selected_nodes")


func shallow_delete_selected_nodes() -> void:
    working_dialogue_manager.commit_action("Shallow Delete Selected Nodes", self, "_shallow_delete_selected_nodes")


func _copy_selected_node_ids_to_clipboard(header: String) -> void:
    var id_string := header

    for id in graph_renderer.selected_node_ids:
        id_string += str(id) + ","

    OS.clipboard = id_string


func _on_working_dialogue_changed() -> void:
    var dialogue := working_dialogue_manager.resource

    # set new dialogue to graph renderer
    if graph_renderer:
        graph_renderer.dialogue = dialogue

    # set selected nodes to action condition widget
    _update_action_condition_selected_nodes()


func _set_dialogue_editor_version() -> void:
    # have to do this indirectly
    # because "manager.resource.version = ..." triggers setter for resource jfc
    var res = working_dialogue_manager.resource
    res.editor_version = _session.dialogue_editor.editor_config.get_value("plugin", "version", "0.0.0")


func _update_action_condition_selected_nodes() -> void:
    var dialogue := working_dialogue_manager.resource
    if action_condition_widget:
        action_condition_widget.clear_selected_node()
        if dialogue and graph_renderer:
            var selected_nodes = _get_selected_nodes(dialogue)
            for node in selected_nodes:
                action_condition_widget.select_node(node)


func _get_selected_nodes(dialogue: Dialogue) -> Array:
    return dialogue.get_nodes_by_ids(graph_renderer.selected_node_ids)


static func _unroll_referenced_node_id(referenced_node_id: int, nodes: Dictionary) -> int:
    while nodes.has(referenced_node_id) and nodes[referenced_node_id] is ReferenceDialogueNode:
        referenced_node_id = nodes[referenced_node_id].referenced_node_id
    return referenced_node_id


func _shallow_duplicate_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _duplicate_nodes(dialogue, false)


func _deep_duplicate_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _duplicate_nodes(dialogue, true)


func _duplicate_node(dialogue: Dialogue, node: DialogueNode, deep_duplicate: bool) -> DialogueNode:
    var new_node: DialogueNode = node.clone()
    new_node.id = dialogue.get_new_max_id()
    new_node.children = []

    if deep_duplicate:
        for child in node.children:
            var duplicate_node := _duplicate_node(dialogue, child, true)
            new_node.add_child(duplicate_node)
            _look_at_nodes.push_back(duplicate_node)

    return new_node


func _duplicate_nodes(dialogue: Dialogue, deep_duplicate: bool) -> Dialogue:
    var selected_nodes = _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    var have_duplicated = false
    for node in selected_nodes:
        if node.parent_id != -1:
            var parent: DialogueNode = dialogue.nodes[node.parent_id]
            var dup = _duplicate_node(dialogue, node, deep_duplicate)
            parent.add_child(dup, parent.get_child_position(node) + 1)
            _look_at_nodes.push_back(node)
            _look_at_nodes.push_back(dup)
            have_duplicated = true
    if not have_duplicated:
        print("No Nodes Duplicated")
        return null

    dialogue.update_nodes()

    return dialogue


# args = {"with_children": bool, "as_parent": bool}
func _paste_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var id_string := OS.clipboard

    # check that clipboard contains node ids
    if id_string.find(COPY_NODES_STRING_HEADER) == 0:
        return _paste_copied_nodes(dialogue, id_string)
    if id_string.find(CUT_NODES_STRING_HEADER) == 0:
        var with_children: bool = args["with_children"]
        if args["as_parent"]:
            return _paste_cut_node_as_parent(dialogue, id_string, with_children)
        else:
            return _paste_cut_nodes_as_children(dialogue, id_string, with_children)

    print("Clipboard doesn't have nodes!")
    return null


func _paste_copied_nodes(dialogue: Dialogue, id_string: String) -> Dialogue:
    # remove header
    id_string = id_string.substr(COPY_NODES_STRING_HEADER.length())

    # cash selected node ids
    var selected_nodes := _get_selected_nodes(dialogue)

    # check selected node validity
    if selected_nodes.size() < 1:
        print("No parent node selected!")
        return null

    # add references to copied nodes as children in each currently selected node
    var success := false
    var pasted_node_ids := id_string.split(",", false)
    for parent in selected_nodes:
        if graph_renderer.collapsed_nodes.has(parent.id):
            print("Can't paste into collapsed node!")
            continue

        if parent is ReferenceDialogueNode:
            print("Can't paste into reference node!")
            continue

        for pasted_id in pasted_node_ids:
            pasted_id = int(pasted_id)
            if dialogue.nodes.has(pasted_id):
                var ref_node := _make_reference_node(pasted_id, dialogue)
                parent.add_child(ref_node)
                _look_at_nodes.push_back(ref_node)
                success = true

    if not success:
        return null

    dialogue.update_nodes()

    return dialogue


func _paste_cut_nodes_as_children(dialogue: Dialogue, id_string: String, paste_with_children: bool) -> Dialogue:
    # remove header
    id_string = id_string.substr(CUT_NODES_STRING_HEADER.length())

    # cash selected node ids
    var selected_nodes := _get_selected_nodes(dialogue)

    # check selected node validity
    if selected_nodes.size() < 1:
        print("No parent node selected!")
        return null
    if selected_nodes.size() > 1:
        print("Can only paste cut nodes into one parent!")
        return null

    var parent: DialogueNode = selected_nodes[0]
    if graph_renderer.collapsed_nodes.has(parent.id):
        print("Can't paste into collapsed node!")
        return null
    if parent is ReferenceDialogueNode:
        print("Can't paste into reference node!")
        return null

    # get node references by ids
    var pasted_node_ids := id_string.split(",", false)
    var pasted_nodes := []
    for pasted_id in pasted_node_ids:
        pasted_id = int(pasted_id)
        if dialogue.nodes.has(pasted_id):
            var node: DialogueNode = dialogue.nodes[pasted_id]
            if node is RootDialogueNode:
                print("Can't cut root node!")
                continue
            pasted_nodes.push_back(node)

    if dialogue.make_children_of_node(pasted_nodes, parent, paste_with_children):
        if paste_with_children:
            for pasted_node in pasted_nodes:
                _look_at_nodes.append_array(dialogue.get_branch(pasted_node))
        else:
            _look_at_nodes.append_array(pasted_nodes)

        _look_at_nodes.push_back(parent)

        return dialogue
    return null


func _paste_cut_node_as_parent(dialogue: Dialogue, id_string: String, paste_with_children: bool) -> Dialogue:
    # remove header
    id_string = id_string.substr(CUT_NODES_STRING_HEADER.length())

    # cash selected node ids
    var selected_nodes := _get_selected_nodes(dialogue)

    # check selected node validity
    if selected_nodes.size() < 1:
        print("No child node selected!")
        return null
    if selected_nodes.size() > 1:
        print("Can only paste cut node into as parent of one child!")
        return null

    var new_child: DialogueNode = selected_nodes[0]

    # get node references by ids
    var pasted_node_ids := id_string.split(",", false)
    if pasted_node_ids.size() != 1:
        print("Can only paste one node as parent!")
        return null

    var pasted_id := int(pasted_node_ids[0])
    if not dialogue.nodes.has(pasted_id):
        print("Invalid cut node id!")
        return null

    var pasted_node: DialogueNode = dialogue.nodes[pasted_id]
    if pasted_node is RootDialogueNode:
        print("Can't cut root node!")
        return null
    if pasted_node is ReferenceDialogueNode:
        print("Can't paste reference node as parent!")
        return null

    if dialogue.make_parent_of_node(pasted_node, new_child, paste_with_children):
        graph_renderer.uncollapse_node(pasted_node)

        if paste_with_children:
            _look_at_nodes.append_array(dialogue.get_branch(pasted_node))
        else:
            _look_at_nodes.push_back(pasted_node)

        _look_at_nodes.push_back(new_child)

        return dialogue
    return null


func _make_reference_node(referenced_node_id: int, dialogue: Dialogue) -> ReferenceDialogueNode:
    var ref_node := ReferenceDialogueNode.new()
    ref_node.id = dialogue.get_new_max_id()
    ref_node.referenced_node_id = _unroll_referenced_node_id(referenced_node_id, dialogue.nodes)
    if dialogue.nodes[referenced_node_id] is ReferenceDialogueNode:
        ref_node.jump_to = dialogue.nodes[referenced_node_id].jump_to
    return ref_node


func _insert_child_hear_node(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _insert_child_node(dialogue, HearDialogueNode.new())


func _insert_child_say_node(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _insert_child_node(dialogue, SayDialogueNode.new())


func _insert_parent_hear_node(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _insert_parent_node(dialogue, HearDialogueNode.new())


func _insert_parent_say_node(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _insert_parent_node(dialogue, SayDialogueNode.new())


func _auto_set_actors(target_node: TextDialogueNode, reference_node: TextDialogueNode) -> void:
    if not target_node or not reference_node:
        return

    if target_node.get_script() == reference_node.get_script():
        target_node.speaker = reference_node.speaker
        target_node.listener = reference_node.listener
    else:
        target_node.speaker = reference_node.listener
        target_node.listener = reference_node.speaker


func _insert_parent_node(dialogue: Dialogue, node: DialogueNode) -> Dialogue:
    var selected_nodes = _get_selected_nodes(dialogue)
    if selected_nodes.size() != 1:
        print("Can't add parent to multiple nodes at once!")
        return null

    var cur_node: DialogueNode = selected_nodes[0]
    if cur_node as RootDialogueNode:
        print("Can't add parent to root node!")
        return null

    node.id = dialogue.get_new_max_id()

    var cur_parent = dialogue.nodes[cur_node.parent_id]
    var indx =  cur_parent.children.find(cur_node)
    cur_parent.children[indx] = node
    node.parent_id = cur_node.parent_id
    node.add_child(cur_node)
    _auto_set_actors(node, cur_node)

    dialogue.update_nodes()

    _look_at_nodes.push_back(node)
    _look_at_nodes.push_back(cur_node)

    return dialogue


func _insert_child_node(dialogue: Dialogue, node: DialogueNode) -> Dialogue:
    var selected_nodes := _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    node.id = dialogue.get_new_max_id()

    var first_parent := true
    for parent in selected_nodes:
        if graph_renderer.collapsed_nodes.has(parent.id):
            print("Can't add child to collapsed node!")
            continue
        if parent is ReferenceDialogueNode:
            print("Can't add child to reference node!")
            continue

        _look_at_nodes.push_back(parent)

        if first_parent:
            parent.add_child(node)
            _auto_set_actors(node, parent)
            _look_at_nodes.push_back(node)
            first_parent = false
        else:
            var ref_node := _make_reference_node(node.id, dialogue)
            parent.add_child(ref_node)
            _look_at_nodes.push_back(ref_node)

    if first_parent:
        return null

    dialogue.update_nodes()

    return dialogue


func _deep_delete_selected_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _delete_selected_nodes(dialogue, false)


func _shallow_delete_selected_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _delete_selected_nodes(dialogue, true)


func _delete_selected_nodes(dialogue: Dialogue, save_children: bool) -> Dialogue:
    var nodes_to_delete := _get_selected_nodes(dialogue)
    if nodes_to_delete.empty():
        return null

    while not nodes_to_delete.empty():
        # extract node from queue
        var node: DialogueNode = nodes_to_delete.pop_front()

        # can't delete root node
        if node is RootDialogueNode:
            continue

        var node_parent: DialogueNode = dialogue.nodes[node.parent_id]

        var deleted_pos := node_parent.get_child_position(node)

        if save_children:
            # reassign children to deleted node parent
            for i in range(node.children.size()):
                node_parent.add_child(node.children[i], deleted_pos + i)
        else:
            # add children to delete queue
            for child in node.children:
                nodes_to_delete.push_back(child)

        # delete node from parent
        node_parent.children.erase(node)

        # find references to node and add them to delete queue as well
        for other_node in dialogue.nodes.values():
            var ref_node := other_node as ReferenceDialogueNode
            if ref_node and ref_node.referenced_node_id == node.id:
                nodes_to_delete.push_back(ref_node)

    dialogue.update_nodes()

    return dialogue


func _on_collapsed_nodes_changed() -> void:
    _update_action_condition_selected_nodes()


func _on_node_selected(node: Node) -> void:
    if action_condition_widget and node is DialogueNodeRenderer:
        action_condition_widget.select_node(node.node)


func _on_node_unselected(node: Node) -> void:
    if action_condition_widget and node is DialogueNodeRenderer:
        action_condition_widget.unselect_node(node.node)


func _on_working_dialogue_manager_file_changed() -> void:
    if action_condition_widget:
        action_condition_widget.clear_selected_node()


func _on_working_dialogue_manager_save_path_changed():
    emit_signal("title_changed", get_title())


func _on_working_dialogue_manager_has_unsaved_changes_changed(value):
    if value:
        emit_signal("title_changed", "%s(*)" % get_title())
    else:
        emit_signal("title_changed", get_title())


func _on_graph_renderer_copy_nodes_request():
    copy_selected_nodes()


func _on_graph_renderer_paste_nodes_request():
    if Input.is_key_pressed(KEY_SHIFT):
        if Input.is_key_pressed(KEY_ALT):
            paste_cut_node_with_children_as_parent()
        else:
            paste_cut_node_as_parent()
    else:
        if Input.is_key_pressed(KEY_ALT):
            paste_cut_nodes_with_children()
        else:
            paste_nodes()


func _on_graph_renderer_delete_nodes_request(nodes: Array = []):
    if Input.is_key_pressed(KEY_SHIFT):
        deep_delete_selected_nodes()
    else:
        shallow_delete_selected_nodes()


func _on_graph_renderer_duplicate_nodes_request():
    if Input.is_key_pressed(KEY_SHIFT):
        deep_duplicate_selected_nodes()
    else:
        shallow_duplicate_selected_nodes()


# args = {"shift"}
func _move_selected_nodes_vertically(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var shift: int = args["shift"]
    var selected_nodes := _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    var filtered_selected_nodes := []
    for node in selected_nodes:
        var parent := dialogue.get_node(node.parent_id)
        if not parent:
            continue
        filtered_selected_nodes.append(node)
        var pos = parent.get_child_position(node)
        var new_pos = clamp(pos + shift, 0, parent.children.size() - 1)
        shift = sign(shift) * min(abs(new_pos - pos), abs(shift))

    if filtered_selected_nodes.empty() or shift == 0:
        print("No Nodes Moved")
        return null

    filtered_selected_nodes.sort_custom(Dialogue.NodeVerticalSorter.new(dialogue.nodes, shift > 0), "less_than")

    for node in filtered_selected_nodes:
        var parent := dialogue.get_node(node.parent_id)
        assert(parent)
        var pos = parent.get_child_position(node)
        assert(0 <= pos + shift)
        assert(pos + shift <= parent.children.size() - 1)
        parent.children.erase(node)
        parent.children.insert(pos + shift, node)

    return dialogue


func _commit_text_changes():
    # unfocus text and wait 2 frames for changes to get commited
    focus_mode = Control.FOCUS_ALL
    grab_focus()
    focus_mode = Control.FOCUS_NONE
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
