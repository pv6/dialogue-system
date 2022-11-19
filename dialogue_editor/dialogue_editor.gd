tool
extends Control


signal open_dialogue_error()

const COPY_NODES_STRING_HEADER := "node ids:"

var session: DialogueEditorSession = preload("session.tres")

var _editor_config := ConfigFile.new()

# for tag editor
# i am sorry ok i just didn't care to make a whole new class for this one field
var _edited_text_node_id: int

onready var graph_renderer: DialogueGraphRenderer = $VBoxContainer/TabContainer/HSplitContainer/DialogueGraphRenderer
onready var action_condition_widget: ActionConditionWidget = $VBoxContainer/TabContainer/HSplitContainer/ActionConditionWidget
onready var actors_editor: AcceptDialog = $ActorsEditor
onready var tags_editor: AcceptDialog = $TagsEditor
onready var dialogue_blackboards_editor: AcceptDialog = $DialogueBlackboardsEditor
onready var blackboard_editor: AcceptDialog = $BlackboardEditor
onready var global_actors_editor: AcceptDialog = $GlobalActorsEditor
onready var global_tags_editor: AcceptDialog = $GlobalTagsEditor

onready var _working_dialogue_manager: WorkingResourceManager = $WorkingDialogueManager
onready var _tab_container: TabContainer = $VBoxContainer/TabContainer


func _init() -> void:
    session.clear_connections()
    session.dialogue_editor = self
    session.connect("changed", self, "_on_session_changed")

    _editor_config.load("res://addons/dialogue_system/plugin.cfg")


func _ready() -> void:
    _working_dialogue_manager.connect("resource_changed", self, "_on_working_dialogue_changed")
    session.dialogue_undo_redo = _working_dialogue_manager

    # set open global editors callback functions to GUI buttons
    actors_editor.storage_editor.item_editor.connect(
        "edit_storage_pressed", self, "open_global_actors_editor")
    tags_editor.storage_editor.item_editor.connect(
        "edit_storage_pressed", self, "open_global_tags_editor")

    new_dialogue()


func undo() -> void:
    _working_dialogue_manager.undo()


func redo() -> void:
    _working_dialogue_manager.redo()


func copy_selected_nodes() -> void:
    var id_string = COPY_NODES_STRING_HEADER

    for id in graph_renderer.selected_node_ids:
        id_string += str(id) + ","

    OS.clipboard = id_string


func shallow_dublicate_selected_nodes() -> void:
    _working_dialogue_manager.commit_action("Shallow Dublicate Selected Nodes", self, "_shallow_dublicate_nodes")


func deep_dublicate_selected_nodes() -> void:
    _working_dialogue_manager.commit_action("Deep Dublicate Selected Nodes", self, "_deep_dublicate_nodes")


func move_selected_nodes_up() -> void:
    _working_dialogue_manager.commit_action("Move Selected Nodes Up", self, "_move_selected_nodes_up")


func move_selected_nodes_down() -> void:
    _working_dialogue_manager.commit_action("Move Selected Nodes Down", self, "_move_selected_nodes_down")


func paste_nodes() -> void:
    _working_dialogue_manager.commit_action("Paste Nodes", self, "_paste_nodes")


func insert_parent_hear_node() -> void:
    _working_dialogue_manager.commit_action("Insert Parent Hear Node", self, "_insert_parent_hear_node")


func insert_parent_say_node() -> void:
    _working_dialogue_manager.commit_action("Insert Parent Say Node", self, "_insert_parent_say_node")


func insert_child_hear_node() -> void:
    _working_dialogue_manager.commit_action("Insert Child Hear Node", self, "_insert_child_hear_node")


func insert_child_say_node() -> void:
    _working_dialogue_manager.commit_action("Insert Child Say Node", self, "_insert_child_say_node")


func deep_delete_selected_nodes() -> void:
    _working_dialogue_manager.commit_action("Deep Delete Selected Nodes", self, "_deep_delete_selected_nodes")


func shallow_delete_selected_nodes() -> void:
    _working_dialogue_manager.commit_action("Shallow Delete Selected Nodes", self, "_shallow_delete_selected_nodes")


func new_dialogue() -> void:
    print("New Dialogue")
    _working_dialogue_manager.new_file()


func open_dialogue() -> void:
    print("Open Dialogue")
    _working_dialogue_manager.open()


func save_dialogue() -> void:
    print("Save Dialogue")
    _set_dialogue_editor_version()
    _working_dialogue_manager.save()


func save_dialogue_as() -> void:
    print("Save Dialogue As")
    _set_dialogue_editor_version()
    _working_dialogue_manager.save_as()


func open_actors_editor() -> void:
    actors_editor.storage_editor.storage = get_dialogue().actors
    actors_editor.popup_centered()


func open_tags_editor(text_node: TextDialogueNode) -> void:
    tags_editor.storage_editor.storage = text_node.tags
    _edited_text_node_id = text_node.id
    tags_editor.popup_centered()


func open_global_actors_editor() -> void:
    global_actors_editor.storage_editor.storage = session.global_actors
    global_actors_editor.popup_centered()


func open_global_tags_editor() -> void:
    global_tags_editor.storage_editor.storage = session.global_tags
    global_tags_editor.popup_centered()


func open_dialogue_blackboards_editor() -> void:
    dialogue_blackboards_editor.storage_editor.storage = get_dialogue().blackboards
    dialogue_blackboards_editor.popup_centered()


func open_blackboard_editor(blackboard: StorageItem) -> void:
    blackboard_editor.blackboard = blackboard
    blackboard_editor.popup_centered()


func get_dialogue() -> Dialogue:
    return _working_dialogue_manager.resource as Dialogue


static func _unroll_referenced_node_id(referenced_node_id: int, nodes: Dictionary) -> int:
    while nodes.has(referenced_node_id) and nodes[referenced_node_id] is ReferenceDialogueNode:
        referenced_node_id = nodes[referenced_node_id].referenced_node_id
    return referenced_node_id


func _set_dialogue_editor_version() -> void:
    # have to do this indirectly
    # because "manager.resource.version = ..." triggers setter for resource jfc
    var res = _working_dialogue_manager.resource
    res.editor_version = _editor_config.get_value("plugin", "version", "0.0.0")


func _shallow_dublicate_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _dublicate_nodes(dialogue, false)


func _deep_dublicate_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _dublicate_nodes(dialogue, true)


func _dublicate_node(dialogue: Dialogue, node: DialogueNode, deep_dublicate: bool) -> DialogueNode:
    var new_node: DialogueNode = node.clone()
    new_node.id = dialogue.get_new_max_id()
    new_node.children = []

    if deep_dublicate:
        for child in node.children:
            new_node.add_child(_dublicate_node(dialogue, child, true))

    return new_node


func _get_selected_nodes(dialogue: Dialogue) -> Array:
    return dialogue.get_nodes_by_ids(graph_renderer.selected_node_ids)


func _dublicate_nodes(dialogue: Dialogue, deep_dublicate: bool) -> Dialogue:
    var selected_nodes = _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    var have_dublicated = false
    for node in selected_nodes:
        if node.parent_id != -1:
            var parent: DialogueNode = dialogue.nodes[node.parent_id]
            var dub = _dublicate_node(dialogue, node, deep_dublicate)
            parent.add_child(dub, parent.get_child_position(node.id) + 1)
            have_dublicated = true
    if not have_dublicated:
        print("No Nodes Dublicated")
        return null

    dialogue.update_nodes()

    return dialogue


func _paste_nodes(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var id_string := OS.clipboard

    # check that clipboard contains copied node ids
    if not id_string.find(COPY_NODES_STRING_HEADER) == 0:
        return null
    id_string = id_string.substr(COPY_NODES_STRING_HEADER.length())

    # cash selected node ids
    var selected_nodes := _get_selected_nodes(dialogue)

    # add references to copied nodes as children in each currently selected node
    var pasted_node_ids := id_string.split(",", false)
    for parent in selected_nodes:
        if graph_renderer.collapsed_nodes.has(parent.id):
            print("Can't paste into collapsed node!")
            return null
        for pasted_id in pasted_node_ids:
            pasted_id = int(pasted_id)
            if dialogue.nodes.has(pasted_id):
                var ref_node := _make_reference_node(pasted_id, dialogue)
                parent.add_child(ref_node)

    dialogue.update_nodes()

    return dialogue


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


func _insert_parent_node(dialogue: Dialogue, node: DialogueNode) -> Dialogue:
    var selected_nodes = _get_selected_nodes(dialogue)
    if selected_nodes.size() != 1:
        return null

    var cur_node: DialogueNode = selected_nodes[0]
    if cur_node as RootDialogueNode:
        return null

    node.id = dialogue.get_new_max_id()

    var cur_parent = dialogue.nodes[cur_node.parent_id]
    var indx =  cur_parent.children.find(cur_node)
    cur_parent.children[indx] = node
    node.parent_id = cur_node.parent_id
    node.add_child(cur_node)

    if node is HearDialogueNode and cur_node is HearDialogueNode:
        node.speaker = cur_node.speaker
        node.listener = cur_node.listener

    dialogue.update_nodes()

    return dialogue


func _insert_child_node(dialogue: Dialogue, node: DialogueNode) -> Dialogue:
    var selected_nodes = _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    node.id = dialogue.get_new_max_id()

    var first_parent := true
    for parent in selected_nodes:
        if graph_renderer.collapsed_nodes.has(parent.id):
            print("Can't add child to collapsed node!")
            return null
        if first_parent:
            parent.add_child(node)
            if node is HearDialogueNode:
                while not parent is HearDialogueNode and not parent is RootDialogueNode:
                    parent = dialogue.nodes[parent.parent_id]
                if parent is HearDialogueNode:
                    node.speaker = parent.speaker
                    node.listener = parent.listener
            first_parent = false
        else:
            var ref_node := _make_reference_node(node.id, dialogue)
            parent.add_child(ref_node)

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

        var node_parent = dialogue.nodes[node.parent_id]

        if save_children:
            # reassign children to deleted node parent
            for child in node.children:
                node_parent.add_child(child)
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


func _on_working_dialogue_changed() -> void:
    var dialogue := _working_dialogue_manager.resource

    # set new dialogue to graph renderer
    if graph_renderer:
        graph_renderer.dialogue = dialogue

    # set selected nodes to action condition widget
    _update_action_condition_selected_nodes()


func _update_action_condition_selected_nodes() -> void:
    var dialogue := _working_dialogue_manager.resource
    if action_condition_widget:
        action_condition_widget.clear_selected_node()
        if dialogue and graph_renderer:
            var selected_nodes = _get_selected_nodes(dialogue)
            for node in selected_nodes:
                action_condition_widget.select_node(node)


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


func _on_actors_editor_confirmed() -> void:
    if actors_editor.storage_editor.has_changes:
        _working_dialogue_manager.commit_action("Edit Dialogue Actors", self, "_edit_actors")


func _on_tags_editor_confirmed() -> void:
    if tags_editor.storage_editor.has_changes:
        _working_dialogue_manager.commit_action("Edit Node Tags", self, "_edit_tags")


func _on_dialogue_blackboards_editor_confirmed() -> void:
    if dialogue_blackboards_editor.storage_editor.has_changes:
        _working_dialogue_manager.commit_action("Edit Dialogue Blackboards", self, "_edit_blackboards")


func _edit_actors(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.actors = actors_editor.storage_editor.storage
    return dialogue


func _edit_tags(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.nodes[_edited_text_node_id].tags = tags_editor.storage_editor.storage
    return dialogue


func _edit_blackboards(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.blackboards = dialogue_blackboards_editor.storage_editor.storage
    return dialogue


func _on_global_actors_editor_confirmed() -> void:
    session.global_actors = global_actors_editor.storage_editor.storage
    ResourceSaver.save(session.global_actors.resource_path, session.global_actors)


func _on_global_actors_tags_confirmed():
    session.global_tags = global_tags_editor.storage_editor.storage
    ResourceSaver.save(session.global_tags.resource_path, session.global_tags)


func _on_session_changed() -> void:
    actors_editor.storage_editor.item_editor.storage = session.global_actors
    tags_editor.storage_editor.item_editor.storage = session.global_tags


func _get_file_name() -> String:
    if _working_dialogue_manager.save_path == "":
        return "[unsaved]"
    else:
        var path = _working_dialogue_manager.save_path
        return path.get_file().trim_suffix("." + path.get_extension())


func _on_working_dialogue_manager_save_path_changed():
    if _tab_container:
        _tab_container.set_tab_title(0, _get_file_name())


func _on_working_dialogue_manager_has_unsaved_changes_changed(value):
    if _tab_container:
        if value:
            _tab_container.set_tab_title(0, _get_file_name() + "(*)")
        else:
            _tab_container.set_tab_title(0, _get_file_name())


func _on_graph_renderer_copy_nodes_request():
    copy_selected_nodes()


func _on_graph_renderer_paste_nodes_request():
    paste_nodes()


func _on_graph_renderer_delete_nodes_request(nodes: Array = []):
    if Input.is_key_pressed(KEY_SHIFT):
        deep_delete_selected_nodes()
    else:
        shallow_delete_selected_nodes()


func _on_graph_renderer_duplicate_nodes_request():
    if Input.is_key_pressed(KEY_SHIFT):
        deep_dublicate_selected_nodes()
    else:
        shallow_dublicate_selected_nodes()


func _move_selected_nodes_up(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _move_selected_nodes_vertically(dialogue, -1)


func _move_selected_nodes_down(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _move_selected_nodes_vertically(dialogue, 1)


class NodeVerticalSorter:
    var nodes: Dictionary
    var reverse

    func _init(nodes: Dictionary, reverse := false) -> void:
        self.nodes = nodes
        self.reverse = reverse

    func less_than(a: DialogueNode, b: DialogueNode) -> bool:
        if reverse:
            return _get_pos(a) > _get_pos(b)
        return _get_pos(a) < _get_pos(b)

    func _get_pos(node: DialogueNode) -> int:
        return nodes[node.parent_id].get_child_position(node.id)


func _move_selected_nodes_vertically(dialogue: Dialogue, shift: int) -> Dialogue:
    var selected_nodes := _get_selected_nodes(dialogue)
    if selected_nodes.empty():
        return null

    var filtered_selected_nodes := []
    for node in selected_nodes:
        var parent := dialogue.get_node(node.parent_id)
        if not parent:
            continue
        filtered_selected_nodes.append(node)
        var pos = parent.get_child_position(node.id)
        var new_pos = clamp(pos + shift, 0, parent.children.size() - 1)
        shift = sign(shift) * min(abs(new_pos - pos), abs(shift))

    if filtered_selected_nodes.empty() or shift == 0:
        print("No Nodes Moved")
        return null

    filtered_selected_nodes.sort_custom(NodeVerticalSorter.new(dialogue.nodes, shift > 0), "less_than")

    for node in filtered_selected_nodes:
        var parent := dialogue.get_node(node.parent_id)
        assert(parent)
        var pos = parent.get_child_position(node.id)
        assert(0 <= pos + shift)
        assert(pos + shift <= parent.children.size() - 1)
        parent.children.erase(node)
        parent.children.insert(pos + shift, node)

    return dialogue
