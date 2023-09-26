tool
class_name DialogueNodeRenderer
extends GraphNode


const COMMENT_CONTENTS_SCENE = preload("implemented_contents/comment_contents/comment_dialogue_node_contents_renderer.tscn")
const COMBINED_CONTENTS_SCENE = preload("implemented_contents/combined_contents/combined_dialogue_node_contents_renderer.tscn")

const EXPAND_ICON = preload("res://addons/dialogue_system/assets/icons/add.svg")
const COLLAPSE_ICON = preload("res://addons/dialogue_system/assets/icons/collapse.svg")

const CURSOR_STYLEBOX: StyleBoxFlat = preload("cursor_stylebox.tres")

export var contents_scenes := {
    RootDialogueNode: preload("implemented_contents/root_node/root_dialogue_node_contents_renderer.tscn"),
    TextDialogueNode: preload("implemented_contents/text_node/text_dialogue_node_contents_renderer.tscn"),
    ReferenceDialogueNode: preload("implemented_contents/reference_node/reference_dialogue_node_contents_renderer.tscn"),
}

# DialogueNode
export(Resource) var node setget set_node

export(bool) var is_collapsed setget set_is_collapsed

var contents: DialogueNodeContentsRenderer

var style: DialogueNodeStyle setget set_style

var style_manager: DialogueNodeStyleManager = preload("style_manager/style_manager.tres")

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


func _init() -> void:
    theme = Theme.new()
    theme.set_icon("close", "GraphNode", COLLAPSE_ICON)
    add_stylebox_override("breakpoint", CURSOR_STYLEBOX)


func set_node(new_node: DialogueNode) -> void:
    if new_node == node:
        return

    node = new_node

    if new_node:
        title = new_node.get_name()
        show_close = not node.children.empty()

    update_contents()

    var new_style := style_manager.get_style(new_node)
    if style != new_style:
        set_style(new_style)
        _update_slots()

    self_modulate.v = 1
    if node is ReferenceDialogueNode:
        self_modulate.v *= _session.settings.reference_node_brightness


func set_is_collapsed(new_is_collapsed: bool) -> void:
    if new_is_collapsed == is_collapsed:
        return

    is_collapsed = new_is_collapsed
    if theme:
        if is_collapsed:
            theme.set_icon("close", "GraphNode", EXPAND_ICON)
        else:
            theme.set_icon("close", "GraphNode", COLLAPSE_ICON)
    _update_slots()


func update_contents() -> void:
    if not node or not contents or not contents.node or node.get_script() != contents.node.get_script():
        if contents:
            remove_child(contents)
            contents.queue_free()
        contents = create_contents(node)
        if contents:
            add_child(contents)
    else:
        contents.node = node


func set_style(new_style: DialogueNodeStyle) -> void:
    style = new_style
    add_stylebox_override("frame", style.frame_stylebox)
    add_stylebox_override("selectedframe", style.selected_frame_stylebox)


func create_contents(node: DialogueNode) -> DialogueNodeContentsRenderer:
    var output: CombinedDialogueNodeContentsRenderer = COMBINED_CONTENTS_SCENE.instance()

    for node_type in contents_scenes.keys():
        if node is node_type:
            output.add_child_contents(contents_scenes[node_type].instance(), node_type)

    output.add_child_contents(COMMENT_CONTENTS_SCENE.instance())

    output.node = node
    return output


func get_graph_rect() -> Rect2:
    var padding = Vector2.ONE * _session.settings.node_focus_padding
    return Rect2(offset - padding, rect_size + padding * 2)


func _update_slots() -> void:
    set_slot(0, not node is RootDialogueNode, 0, Color.gray, not is_collapsed and not node is ReferenceDialogueNode, 0, Color.gray)
